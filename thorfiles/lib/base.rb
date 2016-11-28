class ThorBase < Thor
  include Thor::Actions
  include Open3

  WORKDIR = File.absolute_path("#{__dir__}/../..")

  private

  # def get_args(method_name, binding)
  #   [
  #       method_name,
  #       method(method_name).parameters.map do |arg|
  #         binding.eval arg[1].to_s
  #       end
  #   ]
  # end

  def submodules
    return @submodules unless @submodules.nil?
    popen2e 'git submodule', chdir: WORKDIR do |stdin, stdout_stderr, wait_thread|
      @submodules = stdout_stderr.read.split("\n").map do |line|
        /.\w+\s(\S+)/.match(line)[1]
      end
    end
    @submodules
  end

  def yarn_install(path = '.')
    options = ENV['THOR_ENV'] == 'development' ?
        '--ignore-engines' : '--production'

    run "cd #{path} && yarn install #{options}"
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

  def parse_package_json(path)
    JSON.parse(File.open("#{WORKDIR}/#{path ? path + '/' : ''}package.json").read, { symbolize_names: true })
  end

  def docker(command, args)
    case command
      when :build
        args[nil] = args[:context] || WORKDIR
    end

    dockerfile_path = args[:file]

    print "BUILDING: #{dockerfile_path}\n"
    args_string = parse_docker_args args

    if File.file? args[:file]
      p "docker #{command} #{args_string}"
      run "docker #{command} #{args_string}"
    else
      print "Couldn't find dockerfile at #{args[:file]}\n"
    end
  end

  def docker_compose(command, service = '', args)
    case command
      when :run
        args[nil] = args[:command] if args[:command]
    end

    file = args[:file]
    print "BUILDING COMPOSITION: #{file}\n"
    args.delete :file
    args_string = parse_docker_args args

    print "Service: #{service}\n"
    if File.file? file
      run "docker-compose -f #{file} #{command} #{args_string} #{service}"
    else
      print "Couldn't find docker composition file at #{file}\n"
    end
  end

  def parse_docker_args(args)
    args.delete :context
    args.delete :command
    args.map do |arg, value|
      "#{'--' unless arg.nil?}#{arg} #{value}"
    end.join(' ')
  end
end
