class Setup < ThorBase
  desc 'setup:submodule <repo name> [tag]', 'setup using git submodules (for dev)'

  def submodule(repo_name, tag = 'latest')
    submodules.each &method(:git_init_and_update)
    p 'build base:'
    # invoke :'docker:build', [:base]
    print `thor docker:build base`
    p 'build storjmodules'
    # invoke :'docker:build', [:storjmodules]
    print `thor docker:build storjmodules`
    p "build #{repo_name}"
    # invoke :'docker:build', [repo_name]
    print `thor docker:build #{repo_name}`
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
    p "WORKDIR: #{WORKDIR}"
    p "WORKDIR: #{WORKDIR}"
    p "WORKDIR: #{WORKDIR}"
    p "WORKDIR: #{WORKDIR}"
    p "WORKDIR: #{WORKDIR}"
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

  def git_init_and_update(repo_name)
    run "git submodule init #{repo_name}"
    run "git submodule update #{repo_name}"
  end
end
