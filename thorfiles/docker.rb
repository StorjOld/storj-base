class Docker < ThorBase
  desc 'build [env]', 'builds a docker container for the given environment (defaults to development)'

  method_option :env, default: :development, aliases: :e
  method_option :tag, aliases: :t, default: :latest
  method_option :'no-cache', type: :boolean

  def build(image_name, version = 'latest')
    @env = options[:env]
    dockerfile_path = "./dockerfiles/#{image_name}-#{@env}.dockerfile"
    tag = "storjlabs/#{image_name}:#{ENV['CONTAINER_TAG'] || version}"
    docker dockerfile_path, :build, tag: tag
  end

  desc 'build_submodule <label>',
       'builds a docker container for the given label'

  method_option :env, default: :development, aliases: :e
  method_option :tag, aliases: :t, default: :latest

  # NB: If `label` matches a submodule name, it is used as the image name,
  # otherwise it is used as the tag to the "storjlabs/storj" image
  #
  # i.e. given a submodule, "billing":
  #
  # the label "billing" would # interpolate
  # to the image name "storjlabs/billing:latest"
  # the label "node-no-conflict" would interpolate
  # to the image name "storjlabs/storj:node-no-conflict"
  def build_submodule(label)
    # @env = options[:env]
    # image_name, tag, dockerfile_dir = [label, options[:tag], "#{label}/dockerfiles"]
    # dockerfile_path = "#{dockerfile_dir}/#{image_name}-#{@env}.dockerfile"
    # docker dockerfile_path, :build, tag: "storjlabs/#{image_name}:#{tag}"

    @env = options[:env]
    image_name, tag, dockerfile_dir =
        (submodules.include? label) ?
                                [label, options[:tag], "#{label}/dockerfiles"] :
                                ['storj', "#{label}:latest", 'dockerfiles']
    dockerfile_path = "#{dockerfile_dir}/#{image_name}-#{@env}.dockerfile"
    docker dockerfile_path, :build, tag: "storjlabs/#{image_name}:#{tag}"
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
        args[''] = WORKDIR
        print "BUILDING: #{dockerfile_path}\n"
    end

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
