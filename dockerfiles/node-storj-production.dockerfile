FROM storjlabs/thor:latest

WORKDIR /storj-base

RUN thor setup:init_and_update_submodules
RUN thor setup:npm_install_storj
RUN thor setup:npm_link_storj
