FROM storjlabs/interpreter:latest

RUN apt-get install -y vim-tiny curl net-tools

RUN mkdir /storj-base
WORKDIR /storj-base

RUN git init
COPY ./thorfiles/index /storj-base/.git/index
COPY .gitmodules /storj-base/.gitmodules

COPY ./dockerfiles/bin/* /usr/local/bin/
RUN chmod a+x /usr/local/bin/*

COPY ./Gemfile /storj-base/Gemfile
RUN bundle i

COPY Thorfile /storj-base/Thorfile
COPY thorfiles /storj-base/thorfiles

#ENTRYPOINT thor
