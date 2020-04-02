FROM ruby:2.6-alpine

WORKDIR /coyote

ARG bundle_without="development test"
ARG database_url
ARG env="production"
ARG base_key
ARG master_key
ARG staging_key

ENV DATABASE_URL ${database_url}
ENV RAILS_ENV ${env:-"production"}
ENV RACK_ENV ${RAILS_ENV}
ENV NODE_ENV ${RAILS_ENV}
ENV RAILS_LOG_TO_STDOUT 1
ENV RAILS_BASE_KEY ${base_key}
ENV RAILS_MASTER_KEY ${master_key}
ENV RAILS_STAGING_KEY ${staging_key}
ENV PORT 3000

RUN apk update \
  && apk upgrade \
  && apk add --update --no-cache \
  build-base \
  git \
  libxml2-dev \
  libxslt-dev \
  nodejs \
  postgresql-client \
  postgresql-dev \
  ruby-json \
  tzdata \
  yaml-dev

# Install (and clean) Gem dependencies
ADD Gemfile* ./
RUN gem install bundler:`tail -1 Gemfile.lock | xargs` --no-document --conservative
RUN bundle config --global frozen 1 \
  && bundle config set without "${bundle_without}" \
  && bundle config build.nokogiri --use-system-libraries \
  && bundle install \
  && rm -rf /usr/local/bundle/cache/*.gem \
  && find /usr/local/bundle/gems/ -name "*.c" -delete \
  && find /usr/local/bundle/gems/ -name "*.o" -delete

# Copy and configure the app
ADD . ./
RUN if [ "$RAILS_ENV" = "production" ]; then RAILS_MASTER_KEY=${master_key} bundle exec rails assets:precompile; fi

# Launch!
EXPOSE $PORT
CMD ./bin/release && bundle exec puma -C config/puma.rb
