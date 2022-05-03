FROM ruby:2.7.6-alpine3.15

WORKDIR /coyote

ARG bundle_without="development test"

RUN apk update \
  && apk upgrade \
  && apk add --update --no-cache --virtual .gyp python2 make g++ \
  build-base \
  git \
  libxml2-dev \
  libxslt-dev \
  nodejs \
  postgresql-client \
  postgresql-dev \
  ruby-json \
  shared-mime-info \
  tzdata \
  yaml-dev \
  yarn

# Copy all dependency files
ADD Gemfile Gemfile.lock package.json yarn.lock ./

# Install (and clean) Gem dependencies
RUN gem install bundler:`tail -1 Gemfile.lock | xargs` --no-document --conservative
RUN bundle config --global frozen 1 \
  && bundle config set without "${bundle_without}" \
  && bundle config build.nokogiri --use-system-libraries \
  && bundle install --jobs=$(getconf _NPROCESSORS_ONLN) \
  && rm -rf /usr/local/bundle/cache/*.gem \
  && find /usr/local/bundle/gems/ -name "*.c" -delete \
  && find /usr/local/bundle/gems/ -name "*.o" -delete

# Install JavaScript dependencies
RUN yarn install

# Accept the remainder of the args (prevents rebuilding gems when we don't need to)
# ARG database_url
ARG env="production"
# ARG base_key
# ARG master_key
# ARG staging_key

# ENV DATABASE_URL ${database_url}
ENV RAILS_ENV ${env:-"production"}
ENV RACK_ENV ${RAILS_ENV}
ENV NODE_ENV ${RAILS_ENV}
ENV RAILS_LOG_TO_STDOUT 1
# ENV RAILS_BASE_KEY ${base_key}
# ENV RAILS_MASTER_KEY ${master_key}
# ENV RAILS_STAGING_KEY ${staging_key}
ENV PORT 3000

# Copy and configure the app
ADD . ./
RUN if [ "$RAILS_ENV" = "production" ]; then bundle exec rails assets:precompile && bundle exec rails assets:precompile:pages; fi

# Launch!
EXPOSE $PORT
CMD ./bin/release && bundle exec puma -C config/puma.rb
