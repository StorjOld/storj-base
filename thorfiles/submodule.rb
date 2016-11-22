class Submodule < ThorBase
  desc 'build <submodule name>', 'Builds docker image (and optionally dep images) for given submodule'

  method_option :deps, aliases: :d, default: false, type: :boolean
  method_option :env, aliases: :e, default: :development, type: :string

  def build(submodule)
    @env = options[:env]

    if options[:deps]
      Docker::build 'thor', options
      Docker::build 'node-storj', options
    end

    git_init_and_update submodule

    composition_yml_path = "#{WORKDIR}/#{submodule}/dockerfiles/#{submodule}-#{@env}.yml"
    docker_compose :build, file: composition_yml_path, context: "#{WORKDIR}/#{submodule}"
  end

  desc 'update', 'Init and update all git submodules given current .git/index and .gitmodules files'

  def update
    if ENV[:CONTEXT] == 'host'
      deinit
      submodules.each &method(:git_init_and_update)
    else
      `docker-compose -f ./dockerfiles/thor.yml run host thor update`
    end
  end

  desc 'deinit', 'Deinit all git submodules'

  method_option :force, aliases: :f, default: false, type: :boolean

  def deinit
    Context.host 'submodule:deinit' do
      force = options[:force] ? '--force' : ''

      submodules.each do |submodule|
        @actions.run "git submodule deinit #{force} #{submodule}"
      end
    end
  end

  desc 'up <submodule name> [service name]', '"Up" a docker composition (or a specific service) for the given submodule'

  method_option :env, default: :development, aliases: :e

  def up(submodule, service = '')
    Context.host 'submodule:up', submodule, service do
      @env = options[:env]
      composition_yml = "#{WORKDIR}/submodule/dockerfiles/#{submodule}-#{@env}.yml"
      docker_compose composition_yml, 'up', service: service
    end
  end

  desc 'run <submodule name> <service name> [command]', 'Run a one-off command in the specified service for the given submodule\'s composition'

  method_option :env, default: :development, aliases: :e

  def run(submodule, service, command = '')
    Context.host 'submodule:run', submodule, service, command do
      @env = options[:env]
      composition_yml = "#{WORKDIR}/submodule/dockerfiles/#{submodule}-#{@env}.yml"
      docker_compose composition_yml, 'run', service: service, command: command
    end
  end
end
