module Utils
  WORKDIR = File.absolute_path("#{__dir__}/../..")
end

# Require all .rb files recursively from ./utils/
Dir["#{__dir__}/utils/*{,*/*}.rb"].each {|file| require_relative file}
