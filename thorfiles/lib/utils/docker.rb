module Utils
  module Docker
    def docker(command, args)
      case command
        when :build
          args[nil] = args[:context] || WORKDIR
      end

      dockerfile_path = args[:file]

      print "BUILDING: #{dockerfile_path}\n"
      args_string = parse_docker_args args

      if File.file? args[:file]
        p "docker #{command} #{args_string}"
        run "docker #{command} #{args_string}"
      else
        print "Couldn't find dockerfile at #{args[:file]}\n"
      end
    end

    def docker_compose(command, service = '', args)
      case command
        when :run
          args[nil] = args[:command] if args[:command]
      end

      file = args[:file]
      print "BUILDING COMPOSITION: #{file}\n"
      args.delete :file
      args_string = parse_docker_args args

      print "Service: #{service}\n"
      if File.file? file
        run "docker-compose -f #{file} #{command} #{args_string} #{service}"
      else
        print "Couldn't find docker composition file at #{file}\n"
      end
    end

    def parse_docker_args(args)
      args.delete :context
      args.delete :command
      args.map do |arg, value|
        "#{'--' unless arg.nil?}#{arg} #{value}"
      end.join(' ')
    end
  end

  include Docker
end
