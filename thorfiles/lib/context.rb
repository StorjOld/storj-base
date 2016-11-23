# module Context
#   def self.host(task, *args, &block)
#     if ENV['CONTEXT'] == 'host'
#       p 'IN HOST CONTEXT'
#       yield
#     else
#       p 'IN CONTAINER CONTEXT'
#       p "docker-compose -f ./dockerfiles/thor.yml run host thor #{task} #{args.join(' ')}"
#       print `docker-compose -f ./dockerfiles/thor.yml run host thor #{task} #{args.join(' ')}`
#       p
#     end
#   end
#
#   def self.container(task, *args, &block)
#     if ENV['CONTEXT'] == 'container'
#       p 'IN CONTAINER CONTEXT'
#       yield
#     else
#       p 'IN HOST CONTEXT'
#       p "docker-compose -f ./dockerfiles/thor.yml run container thor #{task} #{args.join(' ')}"
#       print `docker-compose -f ./dockerfiles/thor.yml run container thor #{task} #{args.join(' ')}`
#       p
#     end
#   end
# end


# # Usage:
# Context::host *get_args(__method__, binding) do
#   # ...
# end
