class Docker < ThorBase
  desc 'build [env]', 'builds a docker container for the given environment (defaults to development)'

  method_option :env, default: :development, aliases: :e
  method_option :tag, aliases: :t, default: :latest
  method_option :'no-cache', type: :boolean

  def build(image_name, version = 'latest')
    @env = options[:env]
    dockerfile_path = "#{WORKDIR}/dockerfiles/#{image_name}-#{@env}.dockerfile"
    tag = "storjlabs/#{image_name}:#{ENV['CONTAINER_TAG'] || version}"
    docker dockerfile_path, :build, tag: tag
  end

  desc 'build_submodule <submodule>',
       'builds a docker container for the given submodule'

  method_option :env, default: :development, aliases: :e
  method_option :tag, aliases: :t, default: :latest

  def build_submodule(submodule)
    @env = options[:env]
    tag = options[:tag]
    dockerfile_path = "#{WORKDIR}/#{submodule}/dockerfiles/#{submodule}-#{@env}.dockerfile"
    docker dockerfile_path, :build, tag: "storjlabs/#{submodule}:#{tag}", context: "#{WORKDIR}/#{submodule}"
  end

  desc 'build-composition <composition_name>',
       'builds the given docker composition '

  method_option :env, default: :development, aliases: :e
  method_option :tag, aliases: :t, default: :latest

  def build_composition(composition_name)
    @env = options[:env]
    composition_yml = "dockerfiles/#{composition_name}/#{composition_name}-#{options[:env]}.yml"
    docker_compose composition_yml, 'build'
  end

  desc 'up <composition_name>',
       'starts up the given docker composition'

  method_option :env, default: :development, aliases: :e
  method_option :tag, aliases: :t, default: :latest

  def up(composition_name)
    @env = options[:env]
    composition_yml = "dockerfiles/#{composition_name}/#{composition_name}-#{options[:env]}.yml"
    docker_compose composition_yml, 'up'

  end

  private

  def docker(dockerfile_path, command, args)
    case command
      when :build
        args[:file] = dockerfile_path
        args[''] = args[:context] || WORKDIR
        print "BUILDING: #{dockerfile_path}\n"
    end

    args.delete :context
    args_string = args.map { |arg, value| "--#{arg} #{value}" }.join(' ')
    print "docker #{command} #{args_string}\n"
    run "docker #{command} #{args_string}"
  end

  def docker_compose(composition_yml_path, command)
    if File.file? composition_yml_path
      popen2e "docker-compose -f #{composition_yml_path} #{command}", chdir: WORKDIR do |stdin, stdout_stderr, wait_thread|
        while line = stdout_stderr.gets do
          print line
        end
      end
    else
      print "Couldn't find docker composition file at #{composition_yml_path}\n"
    end
  end
end
