.SILENT:
.DEFAULT:

help: using longdesc

using:
	#TODO: change `using` text based on set provider
	echo "using docker provider"

shortdesc:
	echo 'thor	- start an interactive thor container with /bin/bash' | fold -s

longdesc:
	echo 'Usage: `make thor`' | fold -s
	echo ''
	echo 'Start a new interactive thor container with /bin/bash' | fold -s
	echo ''

# Default goal name is `run` instead of matching all, to reduce complexity

run:
	$(MAKE) build ensure_thor
	docker run --rm -it -v `pwd`:/storj-base dockerfiles_thor /bin/bash;

%:
	:
# all goals are phony, this ensures that if there is a
# directory with the same name as a goal, it still works
.PHONY: all
