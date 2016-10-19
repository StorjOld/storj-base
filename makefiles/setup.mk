.SILENT:
.DEFAULT:

help: using longdesc
	echo 'Available repos'
	echo '---------------'
	git submodule status | sed 's/.*[[:space:]]\([[:graph:]]*\)/\1/'

using:
	#TODO: change `using` text based on set provider
	echo "using docker provider"

shortdesc:
	echo 'setup	- init and update git submodules for the specified <repo> and its deps' | fold -s

longdesc:
	echo 'Usage: `make setup <repo>`' | fold -s
	echo ''
	echo 'Init and update git submodules for the specified <repo> and its deps' | fold -s
	echo ''

# Default goal name is `run` instead of matching all, to reduce complexity

REPO_NAME = $(word 2,$(MAKECMDGOALS))
GITHUB_USERNAME = $(word 3, $(MAKECMDGOALS))

run:
	$(MAKE) build ensure_thor
	docker-compose -f dockerfiles/thor.yml run --rm thor thor setup:submodule $(REPO_NAME) $(GITHUB_USERNAME); \

%:
	:
# all goals are phony, this ensures that if there is a
# directory with the same name as a goal, it still works
.PHONY: all
