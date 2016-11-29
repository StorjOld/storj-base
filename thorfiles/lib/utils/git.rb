module Utils
  module Git
    def submodules
      return @submodules unless @submodules.nil?
      popen2e 'git submodule', chdir: WORKDIR do |stdin, stdout_stderr, wait_thread|
        @submodules = stdout_stderr.read.split("\n").map do |line|
          /.\w+\s(\S+)/.match(line)[1]
        end
      end
      @submodules
    end

    def git_init_and_update(repo_name)
      git_init repo_name
      git_update repo_name
    end

    def git_init(repo_name)
      run "git submodule init #{repo_name}"
    end

    def git_update(repo_name)
      run "git submodule update --remote #{repo_name}"
    end
  end

  include Git
end
