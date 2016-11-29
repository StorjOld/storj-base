#! /bin/bash

ARGS='container thor help'

if [ "$#" -gt 0 ]; then
	ARGS="container thor $*"
fi

if [ "$1" == "bash:host" ]; then
  echo "Please run \`./host.sh bash:host\` instead"
  exit 1
fi

if [ "$1" == "bash:container" ]; then
  ARGS="container /bin/bash"
fi

if [ "$1" == "--update" ]; then
  ARGS="container thor docker:build thor"
fi

docker-compose -f ./dockerfiles/thor.yml run $ARGS

