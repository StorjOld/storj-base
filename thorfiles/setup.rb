class Setup < ThorBase
  desc 'submodule <repo name> [version]', 'setup using git submodules (for dev)'

  def submodule(repo_name, version = 'latest')
    run 'thor docker:build thor'
    run 'thor docker:build node-storj'
    run "thor docker:build_submodule #{repo_name}"
  end

  desc 'init_and_update_submodules', 'run git submodule init & update for all submodules'

  def init_and_update_submodules
    submodules.each &method(:git_init_and_update)
  end

  desc 'npm_link_storj', 'npm links storj modules'

  def npm_link_storj
    submodules.each do |submodule|
      run "ln -s #{WORKDIR}/node_modules #{WORKDIR}/#{submodule}/node_modules"
      # run "cd #{submodule} && npm install"

      # run "cd #{submodule} && npm link"
      # package = parse_package_json submodule
      # package[:dependencies].each do |name, version|
      #   # TODO: this isn't the best way to test if a module shoould be linked
      #   if /^storj-/.match name
      #     run "npm link #{name}"
      #   end
      # end
    end
  end

  desc 'npm_install_storj', 'installs npm base modules for storj'

  def npm_install_storj
    p "npm install submodule deps: #{submodules}"
    storj_base_package = {
        name: 'storj-base',
        description: 'all deps and devDeps of storj modules',
        dependencies: {},
    }
    submodules.each do |submodule|
      npm_name = parse_package_json(submodule)[:name]
      storj_base_package[:dependencies][npm_name] = "./#{submodule}"
    end

    File.open('package.json', 'w') do |file|
      file.write JSON.dump(storj_base_package)
    end

    run 'cat ./package.json'

    run 'npm install'
  end

  private

  def remove_remotes(repo_name)
    remotes = `git remote`.split "\n"
    remotes.each do |remote|
      run "cd #{repo_name} && git remote remove #{remote}"
    end
  end

  def git_set_remotes(repo_name)
    run "cd #{repo_name} && git remote add origin https://github.com/Storj/#{repo_name}"
  end

  def parse_package_json(path)
    JSON.parse(File.open("#{WORKDIR}/#{path ? path + '/' : ''}package.json").read, { symbolize_names: true })
  end

  def git_init_and_update(repo_name)
    git_init repo_name
    git_update repo_name
  end

  def git_init(repo_name)
    run "git submodule init #{repo_name}"
  end

  def git_update(repo_name)
    run "git submodule update #{repo_name}"
  end
end
