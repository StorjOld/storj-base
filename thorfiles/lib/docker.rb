class Docker < ThorBase
  desc 'build [env]', 'builds a docker container for the given environment (defaults to development)'

  method_option :env, default: :development, aliases: :e
  method_option :tag, aliases: :t, default: :latest
  method_option :'no-cache', type: :boolean, default: false
  method_option :'build-arg', aliases: :b, type: :string

  def build(image_name, version = 'latest')
    # TODO: do we need @env?
    @env = options[:env]
    dockerfile_path = "#{WORKDIR}/dockerfiles/#{image_name}.dockerfile"
    tag = "storjlabs/#{image_name}:#{ENV['CONTAINER_TAG'] || version}"

    args = {
        tag: tag,
        file: dockerfile_path
    }
    args[:'no-cache'] = '' if options[:'no-cache']
    args[:'build-arg'] = options[:'build-arg'] if options[:'build-arg']

    docker :build, args
  end
end
