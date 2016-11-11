class ThorBase < Thor
  include Thor::Actions
  include Open3

  WORKDIR = File.absolute_path("#{__dir__}/..")

  private

  def submodules
    return @submodules unless @submodules.nil?
    popen2e 'git submodule', chdir: WORKDIR do |stdin, stdout_stderr, wait_thread|
      @submodules = stdout_stderr.read.split("\n").map do |line|
        /.\w+\s(\S+)/.match(line)[1]
      end
    end
    @submodules
  end
end
