FROM ruby:2.3.4
MAINTAINER Mike Subelsky <mike@subelsky.com>
RUN mkdir -p /var/app
COPY Gemfile /var/app/Gemfile
WORKDIR /var/app
RUN bundle install
