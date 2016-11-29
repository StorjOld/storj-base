Dir["#{__dir__}/utils/*{,*/*}.rb"].each {|file| require_relative file}

module Utils
  WORKDIR = File.absolute_path("#{__dir__}/../..")
end
