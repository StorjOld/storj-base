module Utils
  module Misc
    def pre_build(image_name)
      case image_name
        when 'thor'
          # NB: interpolate thorfiles/templates/thor.yml.erb to dockerfiles/thor.yml
          interpolate_template binding,
                               'thor.yml.erb',
                               "#{WORKDIR}/dockerfiles/thor.yml"

          ensure_dot_git_modules_remotes_dirs 'thor'
        else
          print "\n"
      end
    end

    def ensure_dot_git_modules_remotes_dirs(repo_name)
      # NB: ensure .git/refs/remotes directories exist for mounting separate
      # remotes from the host's .git dir
      _submodules = repo_name.nil? ? submodules : [repo_name]
      _submodules.each do |submodule|
        run "mkdir -p #{WORKDIR}/thorfiles/.git/modules/#{submodule}/refs/remotes"
      end
    end
  end

  include Misc
end
