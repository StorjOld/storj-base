FROM storjlabs/storj:thor
COPY .git /storj-base/.git
COPY .gitmodules /storj-base/.gitmodules
RUN thor setup:npm_install_base
