class Bash < ThorBase
  desc 'container', 'get a shell on a thor instance'

  def container
    stubbed
  end

  desc 'host', 'get a shell on a thor instance with project directory mounted at /storj-base'

  def host
    stubbed
  end

  private

  def stubbed
    print <<END_PRINT
Noop - this is a stub to provide documentation.
the bash wrapper on the host should detect the invocation of this task and execute a `docker-compose` command instead.

-- if you're seeing this, you're probably doing it wrong --
END_PRINT
  end
end
