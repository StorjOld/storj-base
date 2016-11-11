FROM storjlabs/thor:latest

WORKDIR /storj-base

RUN thor setup:npm_install_node_no_conflict
RUN thor setup:npm_link_storj
