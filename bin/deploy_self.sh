#!/bin/bash
#usage: deploy_self production

[[ $1 == "development" ]] && exit

cd ~/code/coyote

DATE=$(date +"%Y%m%d%H%M")
DIR=~/backups/coyote_$DATE

mkdir -p $DIR
rsync -az  --copy-links ~/data/coyote/current/* $DIR
RAILS_ENV=$1 bundle exec rake backup:db
mv ../coyote*.sql $DIR

tar -zcvf $DIR.tar.gz  ~/backups
rm -rf $DIR

#deploy
git pull
bundle install
bundle exec cap production deploy
