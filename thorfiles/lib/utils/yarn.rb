module Utils
  module Yarn
    def yarn_install(path = '.')
      options = ENV['THOR_ENV'] == 'development' ?
          '--ignore-engines' : '--production'

      run "cd #{path} && yarn install #{options}"
    end

    def parse_package_json(path)
      JSON.parse(File.open("#{WORKDIR}/#{path ? path + '/' : ''}package.json").read, { symbolize_names: true })
    end
  end

  include Yarn
end
