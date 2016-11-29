require 'erb'

module Utils
  module Erb
    TEMPLATE_DIR = "#{WORKDIR}/thorfiles/templates"

    def interpolate_template(_binding, input_path, output_path = nil)
      file_string = File.open(input_path, 'r').read
      interpolated_string = ERB.new(file_string).result _binding

      return interpolated_string unless output_path

      File.open(output_path, 'w').write interpolated_string
    end
  end

  include Erb
end
