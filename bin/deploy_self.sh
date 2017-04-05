#!/bin/bash
#usage: deploy_self production

[[ $1 == "development" ]] && exit

unset RBENV_DIR RUBYLIB BUNDLER_ORIG_PATH GEM_HOME BUNDLE_PATH PATH BUNDLE_BIN_PATH RUBYOPT RBENV_HOOK_PATH BUNDLE_GEMFILE BUNDLER_VERSION RAILS_ENV
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games


DATE=$(date +"%Y%m%d%H%M")
DIR=~/backups/coyote_$DATE

mkdir -p $DIR
rsync -az  --copy-links ~/data/coyote/current/* $DIR
RAILS_ENV=$1 bundle exec rake backup:db
mv ../coyote*.sql $DIR

tar -zcvf $DIR.tar.gz  $DIR
rm -rf $DIR

#deploy
cd ~/code/coyote
source ~/.bash_profile
RAILS_ENV=development bundle install; bundle exec cap production deploy
