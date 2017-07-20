FROM ruby:2.3.1
MAINTAINER Mike Subelsky <mike@subelsky.com>
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
RUN mkdir /coyote
WORKDIR /coyote
ADD Gemfile /coyote/Gemfile
ADD Gemfile.lock /coyote/Gemfile.lock
RUN gem install bundler && bundle install
ADD . /coyote
