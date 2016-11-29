FROM storjlabs/interpreter:latest

RUN apt-get install -y vim-tiny curl net-tools jq

RUN mkdir /storj-base
WORKDIR /storj-base

COPY ./Gemfile /storj-base/Gemfile
RUN bundle i
RUN git init
COPY ./thorfiles/.git/index /storj-base/.git/index
COPY .gitmodules /storj-base/.gitmodules

COPY ./dockerfiles/bin/* /usr/local/bin/
RUN chmod a+x /usr/local/bin/*


COPY Thorfile /storj-base/Thorfile
COPY thorfiles /storj-base/thorfiles
COPY dockerfiles /storj-base/dockerfiles

#ENTRYPOINT thor
