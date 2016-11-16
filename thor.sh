#! /bin/bash

ARGS='thor help'

if [ "$#" -gt 0 ]; then
	ARGS="thor thor $*"
fi

if [ "$1" == "util:bash" ] || [ "$1" == "bash" ]; then
  ARGS="thor /bin/bash"
fi

docker-compose -f ./dockerfiles/thor-development.yml run $ARGS

