class Submodule < ThorBase
  desc 'add <repo name> [git remote url]', 'Add a new git submodule'

  method_option :branch,
                aliases: :b,
                type: :string,
                default: :master,
                desc: 'Forward `--branch` arg to `git submodule add`'

  def add(repo_name, git_remote_url = 'https://github.com/Storj/%s.git')
    # Interpolate url if applicable
    git_remote_url %= repo_name
    args = {
        name: repo_name,
        branch: options[:branch]
    }

    git_submodule_add git_remote_url, args
    # TODO: should we just go ahead and build thor here?
    pre_build 'thor'
  end

  desc 'build <submodule name> [service name]', 'Builds docker image (and optionally dep images) for given submodule'

  method_option :deps,
                aliases: :d,
                default: false,
                type: :boolean,
                desc: 'Build image dependencies as well (i.e. thor, node-storj)'
  method_option :env,
                aliases: :e,
                type: :string,
                default: :development

  def build(submodule, service = '')
    @env = options[:env]

    gemfile_lock_path = "#{WORKDIR}/Gemfile.lock"
    File.delete gemfile_lock_path if File.file? gemfile_lock_path

    if options[:deps]
      ::Docker.new.build 'thor' #, options
      ::Docker.new.build 'node-storj' #, options
    end

    git_submodule_init_and_update submodule

    composition_yml_path = "#{WORKDIR}/#{submodule}/dockerfiles/#{submodule}-#{@env}.yml"
    docker_compose :build, service, file: composition_yml_path
  end

  desc 'update', 'Init and update all git submodules given current .git/index and .gitmodules files'

  # method_option :force, aliases: :f, default: false, type: :boolean

  def update_all
    deinit_all
    git_submodule_init_and_update '.'
  end

  desc 'deinit', 'Deinit all git submodules'

  method_option :force,
                aliases: :f,
                type: :boolean,
                default: false

  def deinit_all
    git_submodule_deinit '.', force: options[:force]
  end

  desc 'up <submodule name> [service name]', '"Up" a docker composition (or a specific service) for the given submodule'

  method_option :env,
                aliases: :e,
                type: :string,
                default: :development

  def up(submodule, service = '')
    @env = options[:env]
    composition_yml_path = "#{WORKDIR}/#{submodule}/dockerfiles/#{submodule}-#{@env}.yml"
    docker_compose :up, service, file: composition_yml_path
  end

  desc 'run <submodule name> <service name> [command]', 'Run a one-off command in the specified service for the given submodule\'s composition'

  method_option :env, default: :development, aliases: :e

  def command(submodule, service, command = '')
    @env = options[:env]
    composition_yml = "#{WORKDIR}/submodule/dockerfiles/#{submodule}-#{@env}.yml"
    docker_compose composition_yml, 'run', service: service, command: command
  end
end
