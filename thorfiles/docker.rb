class Docker < ThorBase
  include Open3
  include Thor::Actions
  
  desc 'up <env>', 'starts up a docker composition for the given environment'

  def up(env)
    @env = env

    popen2e "docker-compose -f dockerfiles/#{env}.yml up", chdir: WORKDIR do |stdin, stdout_stderr, wait_thread|
      Signal.trap('INT') { shut_down }
      Signal.trap('TERM') { shut_down }

      while line = stdout_stderr.gets do
        print line
      end
    end
  end

  desc 'build [env]', 'builds a docker container for the given environment (defaults to production)'
  method_option :env, default: :development, aliases: :e
  method_option :tag, aliases: :t, default: :latest
  def build(service)
    @env = options[:env]
    run "docker-compose -t storjlabs/#{service}:#{options[:tag]} -f dockerfiles/#{service}-#{options[:env]}.yml build", chdir: WORKDIR
  end

  private

  def shut_down
    spawn("docker-compose -f dockerfiles/#{@env}.yml kill", chdir: WORKDIR)
    sleep 1
    exit
  end
end
