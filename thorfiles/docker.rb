class Docker < ThorBase
  desc 'build [env]', 'builds a docker container for the given environment (defaults to production)'

  method_option :env, default: :development, aliases: :e
  method_option :tag, aliases: :t, default: :latest

  def build(service)
    p "build service: #{service}"
    @env = options[:env]
    popen2e "docker-compose -f dockerfiles/#{service}/#{service}-#{options[:env]}.yml build", chdir: WORKDIR do |stdin, stdout_stderr, wait_thread|
      while line = stdout_stderr.gets do
        print line
      end
    end
  end
end
