class Setup < ThorBase
  include Thor::Actions
  include Open3

  desc 'submodule <project name> <github_username>',
       'looks for "devopsBase" property in package.json and uses git ' +
           'submodule and checkout to ensure specified repo is setup ' +
           'and npm linked'

  def submodule(repo_name, github_username)
    unless git_inited? repo_name
      init_and_update repo_name
      set_remotes repo_name, github_username
    end
    package_json_path = "#{WORKDIR}/#{repo_name}/package.json"
    if File.file? package_json_path
      deps_file = File.open package_json_path
      deps_string = deps_file.read
      devops_property = JSON.parse(deps_string)['devopsBase']

      if !devops_property.nil?
        repo_deps = devops_property['npmLinkDeps']
        p "Initializing deps: #{repo_deps.values.join ', '}"
        repo_deps.each do |npm_name, git_name|
          git_name, refspec = git_name.split('@')
          refspec ||= npm_version npm_name
          git_init_and_update git_name
          git_set_remotes git_name, github_username
          git_checkout git_name, refspec
        end
      else
        print "No local dependencies found in package.json at: #{package_json_path}\n"
      end
    else
      print "Coudn't find a package.json file at: #{package_json_path}\n"
    end
  end

  desc 'clone <docker_project_root>',
       'looks for "devopsBase" property in package.json and clones all deps ' +
           'at correct version and npm linked (defaults to highest semver ' +
           'compatible version in npm)'

  def clone(docker_project_root)
    package_json = File.open "#{docker_project_root}/package.json"
    package_json_string = package_json.read

    @npm_package = JSON.parse(package_json_string)
    npm_link_deps = @npm_package['devopsBase']['npmLinkDeps']
    npm_link_deps.each do |npm_name, git_name|
      git_name, refspec = git_name.split('@')
      refspec ||= "v#{npm_version npm_name}"
      git_clone git_name, refspec
    end
  end

  private

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
    run "git remote set-url origin git@github.com:#{github_username}/#{repo_name}.git"
    run "git remote add storj git@github.com:Storj/#{repo_name}.git"
  end

  def git_checkout(repo_name, refspec)
    run "cd #{repo_name} && git checkout #{refspec}"
  end

  def git_clone(repo_name, refspec)
    run "git clone --depth=1 --single-branch -b #{refspec} https://github.com/Storj/#{repo_name}"
  end

  def npm_version(npm_dep_name)
    npm_version_spec = @npm_package['dependencies'][npm_dep_name]
    desired = "#{npm_dep_name}@#{npm_version_spec}"
    popen2e "npm view #{desired} version" do |stdin, stdout_stderr, wait_thread|
      npm_view = stdout_stderr.read.strip

      matches = npm_view.split("\n").map do |line|
        line.match(/.*'(?<version>.+)'$/).try :[], :version
      end.compact

      if matches.empty?
        throw "No compatible npm version found for: #{desired}"
      end

      result = matches[-1]
      p "Highest compatible npm version: #{npm_dep_name}@#{result}"

      result
    end
  end
end
