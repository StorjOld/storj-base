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

    def git_submodule_init_and_update(repo_name)
      git_submodule_init repo_name
      git_submodule_update repo_name
    end

    def git_submodule_init(repo_name)
      run "git submodule init #{repo_name}"
    end

    def git_submodule_update(repo_name)
      run "git submodule update --remote #{repo_name}"
    end

    def git_submodule_deinit(submodule, force = '')
      run "git submodule deinit #{force} #{submodule}"
    end

    def git_submodule_add(submodule_url, args)
      args_string = parse_args args
      run "git submodule add #{args_string} #{submodule_url}"
    end

    private

    def parse_args(args)
      args.map do |arg, value|
        case value.class
          when TrueClass
            "--#{arg}"
          when FalseClass
            ''
          else
            "--#{arg} #{value}"
        end
      end
    end
  end

  include Git
end
