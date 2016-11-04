class ThorBase < Thor
  include Thor::Actions
  include Open3

  WORKDIR = "#{__dir__}/.."
end
