class Setup < ThorBase
  include Thor::Actions
  include Open3

  def initialize(*args)
    super
    @npm_linked = []
    @git_cloned = {}
    @git_checked_out = {}
  end

  desc 'submodule <project name> <github_username>',
       'looks for "devopsBase" property in package.json and uses git ' +
           'submodule and checkout to ensure specified repo is setup ' +
           'and npm linked'

  def submodule(repo_name, tag = 'latest')
    #unless git_inited? repo_name
    #  git_init_and_update repo_name
    #  git_set_remotes repo_name, github_username
    #end

    #package_path = "#{WORKDIR}/#{repo_name}"
    #parse_deps package_path,
    #           "#{WORKDIR}/?" do |git_name, refspec, npm_refspec|
    #  git_init_and_update git_name
    #  # TODO: maybe set a temp https remote to ensure fetch works
    #  git_set_remotes git_name, github_username
    #  git_fetch_tags git_name
    #  git_checkout git_name, refspec
    #  npm_link git_name
    #  git_clean_remotes git_name
    #end
    submodules.each &method(:git_init_and_update)
    p 'build base:'
    invoke :'docker:build', [:base]
    p 'build storjmodules'
    invoke :'docker:build', [:storjmodules]
    p "build #{repo_name}"
    invoke :'docker:build', [repo_name]
  end

  desc 'clone <docker_project_root>',
       'looks for "devopsBase" property in package.json and clones all deps ' +
           'at correct version and npm linked (defaults to highest semver ' +
           'compatible version in npm)'

  def clone(docker_project_root)
    parse_deps docker_project_root,
               '/storj-base/?' do |git_name, refspec, npm_refspec|
      git_clone git_name, refspec
      npm_link "/storj-base/#{git_name}"
    end
  end

  desc 'npm_install_storj', 'npm installs storj modules'

  def npm_install_storj
    p "SUBMODULES: #{submodules}"
    submodules.each do |submodule|
      p "MODULE: #{submodule}"
      run "cp #{submodule}/package.json package.json"
      run 'npm install'
    end
  end

  desc 'npm_link_storj', 'npm links storj modules'

  def npm_link_storj
    submodules.each do |submodule|
      run "cd #{submodule} && npm link"
      package = parse_package_json submodule
      package.each do |name, version|
        if /^storj-/.match name
          run "npm link #{name}"
        end
      end
    end
  end

  desc 'npm_install_base', 'installs npm base modules for storj'

  def npm_install_base
    p "npm install base submodules: #{submodules}"
    git_init_and_update_submodules
    npm_install_storj
    submodules.each do |submodule|
      p "module: #{submodule}"
      package = parse_package_json submodule
      run "rm -rf #{WORKDIR}/node_modules/#{package['name']}"
    end
  end

  private

  def git_init_and_update_submodules
    submodules.each do |submodule|
      git_init_and_update submodule
    end
  end


  def parse_package_json(path)
    JSON.parse File.open("#{WORKDIR}/#{path ? path + '/' : ''}package.json").read
  end

  def submodules
    return @submodules unless @submodules.nil?
    popen2e 'git submodule', chdir: WORKDIR do |stdin, stdout_stderr, wait_thread|
      out = stdout_stderr.read
      print out
      run 'pwd'
      run 'ls -la'
      @submodules = out.split("\n").map do |line|
        /.\w+\s(\S+)/.match(line)[1]
      end
    end
    p @submodules
    @submodules
  end

  def parse_deps(package_path, package_path_template, repo_name = nil, &block)
    if package_path.nil? && repo_name && package_path_template
      package_path = package_path_template.sub /\?/, repo_name
    end

    package_json_path = package_path + '/package.json'

    if File.file? package_json_path
      deps_file = File.open package_json_path
      npm_package = JSON.parse(deps_file.read)
      devops_property = npm_package['devopsBase']

      if !devops_property.nil?
        repo_deps = devops_property['npmLinkDeps']
        p "Initializing deps: #{repo_deps.values.join ', '}"
        repo_deps.each do |npm_name, git_name|
          # p "git_name: #{git_name}"
          # p "git_name split: #{git_name.split('@')}"
          git_name, refspec = git_name.split('@')
          # p "refspec: #{refspec}"
          npm_version_string = "v#{npm_version npm_package, npm_name}"
          # p "npm_version_string: #{npm_version_string}"
          refspec ||= npm_version_string
          # p "post refspec: #{refspec}"

          unless git_name == repo_name
            yield git_name, refspec, refspec == npm_version_string

            npm_link_dep package_path, npm_name

            parse_deps nil, package_path_template, git_name, &block
          end
        end
      else
        print "No local dependencies found in package.json at: #{package_path}\n"
      end
    else
      print "Coudn't find a package.json file at: #{package_path}\n"
    end
  end

  def git_inited?(repo_name)
    popen2e 'git submodule status' do |stdin, stdout_stderr, wait_thread|
      output = stdout_stderr.read.strip
      init_status = output.split("\n").map do |line|
        line.match(/^(?<init_status>.).+#{repo_name}$/).try :[], :init_status
      end.compact[0]

      init_status == '-' ? false : true
    end
  end

  def git_init_and_update(repo_name)
    run "git submodule init #{repo_name}"
    run "git submodule update #{repo_name}"
  end

  def git_set_remotes(repo_name, github_username)
    run "cd #{repo_name} && git remote add _temp https://github.com/Storj/#{repo_name}"
    run "cd #{repo_name} && git remote set-url origin git@github.com:#{github_username}/#{repo_name}.git"
    run "cd #{repo_name} && git remote add storj git@github.com:Storj/#{repo_name}.git"
  end

  def git_clean_remotes(repo_name)
    run "cd #{repo_name} && git remote remove _temp"
  end

  def git_checkout(repo_name, refspec)
    if @git_checked_out[repo_name] != refspec
      run "cd #{repo_name} && git checkout #{refspec}"
      @git_checked_out[repo_name] = refspec
    else
      p "Didn't checkout #{repo_name}, already checked out to #{@git_checked_out[repo_name]}"
    end
  end

  def git_clone(repo_name, refspec)
    # p "@git_cloned: #{@git_cloned}"
    # p "@git_cloned class: #{@git_cloned.class}"
    if @git_cloned[repo_name] != refspec
      if @git_cloned[repo_name]
        run "rm -rf /storj-base/#{repo_name}"
        @npm_linked.reject! {|module_path| module_path =~ /#{repo_name}$/}
      end
      run "git clone --depth=1 --single-branch -b #{refspec} https://github.com/Storj/#{repo_name} /storj-base/#{repo_name}"
      @git_cloned[repo_name] = refspec
    else
      p "Didn't clone #{repo_name}, already cloned to #{@git_cloned[repo_name]}"
    end
  end

  def git_fetch_tags(repo_name)
    run "cd #{repo_name} && git fetch --tags _temp"
  end

  def npm_link(module_path)
    if !@npm_linked.include? module_path
      p "linking: #{module_path}"
      run "cd #{module_path} && npm link"
      @npm_linked << module_path
    else
      p "Package at #{module_path} already linked!"
    end
  end

  def npm_link_dep(dependant_path, npm_dep_name)
    p "linking #{npm_dep_name} from #{dependant_path}"
    run "cd #{dependant_path} && npm link #{npm_dep_name}"
  end

  def npm_version(npm_package, npm_dep_name)
    if npm_package
      npm_version_spec = npm_package['dependencies'][npm_dep_name]
      desired = "#{npm_dep_name}@#{npm_version_spec}"
      popen2e "npm view #{desired} version" do |stdin, stdout_stderr, wait_thread|
        npm_view = stdout_stderr.read.strip

        print "npm view: #{npm_view}\n"
        matches = npm_view.split("\n").map do |line|
          line.match(/(?:.*')?(?<version>[\d\.]+)'?$/).try :[], :version
        end.compact

        if matches.empty?
          throw "No compatible npm version found for: #{desired}"
        end

        result = matches[-1]
        p "Highest compatible npm version: #{npm_dep_name}@#{result}"

        result
      end
    else
      p "Couldn't look up npm version: no npm package.json available"
    end
  end
end
