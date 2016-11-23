class Setup < ThorBase
  desc 'npm_link_storj', 'npm links storj modules'

  def npm_link_storj
    submodules.each do |submodule|
      run "ln -s #{WORKDIR}/node_modules #{WORKDIR}/#{submodule}/node_modules"
      run "cd #{submodule} && npm link"
      package = parse_package_json submodule
      run "npm link #{package[:name]}"
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
      git_init_and_update submodule
      npm_name = parse_package_json(submodule)[:name]
      storj_base_package[:dependencies][npm_name] = "./#{submodule}"
    end

    File.open('package.json', 'w') do |file|
      file.write JSON.dump(storj_base_package)
    end

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
end
