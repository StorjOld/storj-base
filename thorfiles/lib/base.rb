class ThorBase < Thor
  include Thor::Actions
  include Open3

  WORKDIR = File.absolute_path("#{__dir__}/..")

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

  def parse_package_json(path)
    JSON.parse(File.open("#{WORKDIR}/#{path ? path + '/' : ''}package.json").read, { symbolize_names: true })
  end

  def docker(command, args)
    dockerfile_path = args[:file]

    print "BUILDING: #{dockerfile_path}\n"
    args_string = parse_docker_args command, args

    if File.file? args[:file]
      run "docker #{command} #{args_string}"
    else
      print "Couldn't find dockerfile at #{args[:file]}\n"
    end
  end

  def docker_compose(command, args)
    @service = ''
    print "BUILDING COMPOSITION: #{composition_yml_path}\n"
    file = args[:file]
    args.delete :file
    args_string = parse_docker_args command, args

    if File.file? file
      run "docker-compose -f #{file} #{command} #{args_string} #{@service}"
    else
      print "Couldn't find docker composition file at #{file}\n"
    end
  end

  def parse_docker_args(command, args)
    case command
      when :build
        args[''] = args[:context] || WORKDIR
      when :run
        args[''] = args[:command] if args[:command]
    end

    if args[:service]
      @service = args[:service]
      args.delete :service
    end

    args.delete :context
    args.map { |arg, value| "--#{arg} #{value}" }.join(' ')
  end
end
