FROM storjlabs/thor:latest

WORKDIR /storj-base

RUN thor setup:npm_install_storj
RUN thor setup:npm_link_storj
