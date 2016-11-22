class Docker < ThorBase
  desc 'build [env]', 'builds a docker container for the given environment (defaults to development)'

  method_option :env, default: :development, aliases: :e
  method_option :tag, aliases: :t, default: :latest
  method_option :'no-cache', type: :boolean

  def build(image_name, version = 'latest')
    # TODO: do we need @env?
    @env = options[:env]
    dockerfile_path = "#{WORKDIR}/dockerfiles/#{image_name}.dockerfile"
    tag = "storjlabs/#{image_name}:#{ENV['CONTAINER_TAG'] || version}"
    docker :build, file: dockerfile_path, tag: tag
  end
end
