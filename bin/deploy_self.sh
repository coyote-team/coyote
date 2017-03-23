#!/bin/bash
#usage: deploy_self production

cd ~/code/coyote

DATE=$(date +"%Y%m%d%H%M")
DIR=~/backups/coyote_$DATE

mkdir -p $DIR
rsync -az  --copy-links ~/data/coyote/current/* $DIR
RAILS_ENV=$1 bundle exec rake db:backup
mv ../coyote*.sql $DIR

tar -zcvf ~/backups/$DIR.tar.gz  ~/backups
rm -rf $DIR

#deploy
git pull; bundle exec cap production deploy
