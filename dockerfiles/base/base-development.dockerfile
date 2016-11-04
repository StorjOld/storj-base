FROM storjlabs/thor

WORKDIR /storj-base

RUN thor setup:npm_install_base
