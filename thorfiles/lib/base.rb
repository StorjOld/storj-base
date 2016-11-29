require_relative './utils'

class ThorBase < Thor
  include Thor::Actions
  include Open3

  private
  include Utils

  # stuff here probably should be pushed into utils/*
end
