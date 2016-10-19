FROM devops-base

ADD ./Gemfile /storj-base/Gemfile
ADD ./Gemfile.lock /storj-base/Gemfile.lock

WORKDIR /storj-base

RUN bundle install
