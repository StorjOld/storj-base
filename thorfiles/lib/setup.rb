class Setup < ThorBase
  desc 'npm_link_storj', 'npm links storj modules'

  def npm_link_storj
    submodules.each do |submodule|
      # git_init_and_update submodule
      run "ln -s #{WORKDIR}/node_modules #{WORKDIR}/#{submodule}/node_modules"
      run "cd #{submodule} && yarn link"
      yarn_install submodule
      package = parse_package_json submodule
      run "yarn link #{package[:name]}"
    end
  end

  desc 'npm_install_storj', 'installs npm base modules for storj'

  def npm_install_storj
    get_non_conflicting = -> (key) {
      submodules.reduce({}) do |acc, submodule|
        package_json = parse_package_json submodule
        target = package_json[key]

        next acc unless target

        non_conflicting = target.keys.to_set ^ acc.keys
        next acc.merge(target.select do |key, value|
          non_conflicting.include? key
        end)
      end
    }

    submodules.each &method(:git_submodule_init_and_update)

    non_conflicting_deps = get_non_conflicting.call :dependencies
    non_conflicting_dev_deps = get_non_conflicting.call :devDependencies

    storj_no_conflict = {
        name: 'storj-no-conflict',
        description: 'non-conflicting deps and devDeps of storj modules',
        dependencies: non_conflicting_deps,
        devDependencies: non_conflicting_dev_deps
    }

    File.open('package.json', 'w') do |file|
      file.write JSON.dump(storj_no_conflict)
    end

    yarn_install
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
