FROM ruby

ADD ./Gemfile /storj-meta/Gemfile
#ADD ./Gemfile.lock /storj-meta/Gemfile.lock

WORKDIR /storj-meta

RUN bundle install
