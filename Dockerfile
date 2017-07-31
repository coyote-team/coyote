FROM ruby:2.3.1
MAINTAINER Mike Subelsky <mike@subelsky.com>
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs software-properties-common

RUN add-apt-repository "deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main"
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN apt-get update
RUN apt-get install -y postgresql-client-9.6

RUN mkdir /coyote
WORKDIR /coyote
ADD Gemfile /coyote/Gemfile
ADD Gemfile.lock /coyote/Gemfile.lock
RUN gem install bundler && bundle install
ADD . /coyote
