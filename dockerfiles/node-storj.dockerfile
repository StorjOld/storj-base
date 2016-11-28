FROM storjlabs/thor:latest

WORKDIR /storj-base

ARG THOR_ENV=development

RUN thor setup:npm_install_storj
RUN thor setup:npm_link_storj
