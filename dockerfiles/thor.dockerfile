FROM storjlabs/interpreter:latest

RUN apt-get update && apt install -y vim-tiny curl

ADD ./Gemfile /storj-base/Gemfile
ADD ./Gemfile.lock /storj-base/Gemfile.lock
ADD ./thorfile.thor /storj-base/thorfile.thor
ADD ./thorfiles /storj-base/thorfiles

WORKDIR /storj-base

RUN bundle install
