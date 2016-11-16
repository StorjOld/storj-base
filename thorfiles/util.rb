class Util < ThorBase
  desc 'bash', 'Drop into a bash shell on the thor docker container, mounting project directory at /storj-base'

  def bash
    print <<END_PRINT
Noop - this is a stub to provide documentation.
the bash wrapper on the host should detect the invocation of this task and execute a `docker-compose` command instead.

-- if you're seeing this, you're probably doing it wrong --
END_PRINT
  end
end
