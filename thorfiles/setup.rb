class Setup < ThorBase
  include Open3

  desc 'repo <project name>', 'runs git submodule commmands to ensure specified repo is setup'

  def repo(repo_name)
    deps_file = File.open "#{WORKDIR}/deps.yml"
    deps_string = deps_file.read
    deps_yaml = YAML.load deps_string

    repo_deps = (deps_yaml[repo_name] || []) << repo_name
    repo_deps.each &method(:init_and_update)
  end

  private

  def init_and_update(dep_name)
    # `git submodule init #{dep_name}`
    # `git submodule update #{dep_name}`
    popen2e "git submodule init #{dep_name}" do |stdin, stdout_stderr, wait_thread|
      while line = stdout_stderr.gets do
        print line
      end
    end

    popen2e "git submodule update #{dep_name}" do |stdin, stdout_stderr, wait_thread|
      while line = stdout_stderr.gets do
        print line
      end
    end
  end
end
