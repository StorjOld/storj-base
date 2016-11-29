class Docker < ThorBase
  desc 'build [env]', 'builds a docker container for the given environment (defaults to development)'

  method_option :env,
                aliases: :e,
                type: :string,
                default: :development
  method_option :tag,
                aliases: :t,
                default: :latest,
                desc: 'Specify version portion of tag (e.g. `stable` for `storjlabs/thor:stable`)'
  method_option :'no-cache',
                type: :boolean,
                default: false,
                desc: 'Forward `--no-cache` option to docker build command'
  method_option :'build-arg',
                aliases: :b,
                type: :string,
                desc: 'Forward `--build-arg` option to docker build command'
  method_option :pre,
                aliases: :p,
                type: :boolean,
                desc: 'Runs `pre_build` method only, doesn\'t run docker'

  def build(image_name, version = 'latest')
    pre_build(image_name)

    # Only run `pre_build`
    return if options[:pre]

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
