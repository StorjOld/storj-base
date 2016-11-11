FROM storjlabs/interpreter:latest

WORKDIR /storj-base

COPY .git /storj-base/.git
COPY .gitmodules /storj-base/.gitmodules

COPY ./dockerfiles/bin/* /usr/local/bin/
RUN chmod a+x /usr/local/bin/*

COPY Gemfile /storj-base/Gemfile
RUN bundle i

COPY Thorfile /storj-base/Thorfile
COPY thorfiles /storj-base/thorfiles

#ENTRYPOINT thor
