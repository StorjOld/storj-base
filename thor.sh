#! /bin/bash

ARGS='thor help'

if [ "$#" -gt 0 ]; then
	ARGS="container thor $*"
fi

if [ "$1" == "bash:host" ]; then
  ARGS="host /bin/bash"
fi

if [ "$1" == "bash:container" ]; then
  ARGS="container /bin/bash"
fi

docker-compose -f ./dockerfiles/thor.yml run $ARGS

