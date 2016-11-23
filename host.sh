#! /bin/bash

ARGS='host thor help'

if [ "$#" -gt 0 ]; then
	ARGS="host thor $*"
fi

if [ "$1" == "bash:host" ]; then
  ARGS="host /bin/bash"
fi

if [ "$1" == "bash:container" ]; then
  echo "Please run \`./container.sh bash:container\` instead"
  exit 1
fi

docker-compose -f ./dockerfiles/thor.yml run $ARGS

