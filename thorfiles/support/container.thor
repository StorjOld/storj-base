require 'thor'
require 'open3'
require 'json'

lib_path = './thorfiles/lib'
require_relative lib_path + '/base'
required_files = %w(bash setup submodule docker util)
required_files.each { |file| require_relative "#{lib_path}/#{file}" }
