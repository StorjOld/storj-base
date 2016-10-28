.SILENT:
.DEFAULT:

help: using longdesc

using:
	#TODO: change `using` text based on set provider
	echo "using docker provider"

shortdesc:
	echo 'pry	- start a ruby REPL using pry' | fold -s

longdesc:
	echo 'Usage: `make pry`' | fold -s
	echo ''
	echo 'Start a ruby REPL using [pry](http://pryrepl.org)' | fold -s
	echo ''

# Default goal name is `run` instead of matching all, to reduce complexity

run:
	$(MAKE) build ensure_thor
	docker run --rm -it storjlabs/storj:thor pry;

%:
	:
# all goals are phony, this ensures that if there is a
# directory with the same name as a goal, it still works
.PHONY: all
