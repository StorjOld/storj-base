class Util < ThorBase
  desc 'pry', 'get a pry shell (ruby repl)'

  def pry
    binding.pry
  end
end
