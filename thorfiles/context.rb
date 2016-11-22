module Context
  def host(task, *args, &block)
    if ENV[:CONTEXT] == 'host'
      yield
    else
      `docker-compose -f ./dockerfiles/thor.yml run host thor #{task} #{args.join(' ')}`
    end
  end
end
