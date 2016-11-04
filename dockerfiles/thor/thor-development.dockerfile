FROM storjlabs/storj:base

WORKDIR /storj-base

COPY .git /storj-base/.git
COPY .gitmodules /storj-base/.gitmodules

COPY Gemfile /storj-base/Gemfile
RUN bundle i

COPY Thorfile /storj-base/Thorfile
COPY thorfiles /storj-base/thorfiles
