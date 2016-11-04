FROM storjlabs/base
RUN thor npm_install_storj
RUN thor npm_link_storj
