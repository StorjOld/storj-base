.SILENT:
.DEFAULT:

help: using longdesc

using:
	#TODO: change `using` text based on set provider
	echo "using docker provider"

shortdesc:
	echo 'build	- build the devops container' | fold -s

longdesc:
	echo 'Usage: `make build`' | fold -s
	echo ''
	echo 'Build the devops container. This container is what runs thor commands passed to it by make' | fold -s
	echo ''

# Default goal name is `run` instead of matching all, to reduce complexity

run: ensure_devops_base
	if [ ! $(word 2, $(MAKECMDGOALS)) ]; then \
		docker-compose -f dockerfiles/thor.yml build thor; \
	fi \

ensure_devops_base:
	if ! docker images |grep -q storj.*base; then \
		docker build -t storj:base -f dockerfiles/storj-base.dockerfile .; \
	fi

ensure_thor: ensure_devops_base
	if ! docker images |grep -q storjlabs/storj.*thor; then \
		docker-compose -f dockerfiles/thor.yml -t storjlabs/storj:base build thor; \
	fi

%:
	:
# all goals are phony, this ensures that if there is a
# directory with the same name as a goal, it still works
.PHONY: all
