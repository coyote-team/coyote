#!/bin/bash
# Installs coyote on 16.04 ubuntu given a root login
# usage:
# wget -qO- https://raw.githubusercontent.com/coyote-team/coyote/master/bin/install.sh | bash

# aptitude update, upgrade, requirements, auto-upgrade
apt update -y
export DEBIAN_FRONTEND=noninteractive
apt-get upgrade -y -q
# NOTE grub conflict on linode so keep current grub conf
apt install software-properties-common -y
add-apt-repository 'deb http://nyc2.mirrors.digitalocean.com/mariadb/repo/10.0/ubuntu xenial main'
apt-get install -q -y --allow-unauthenticated graphviz git libpq-dev gawk build-essential libreadline6-dev \
zlib1g-dev libssl-dev libyaml-dev autoconf libgdbm-dev libncurses5-dev automake libtool \
bison pkg-config libffi-dev mariadb-server libmariadb-client-lgpl-dev git make gcc zlib1g-dev \
libssl-dev libreadline6-dev libxml2-dev libsqlite3-dev nginx openssl libreadline6 \
libreadline6-dev curl git-core zlib1g libyaml-dev libsqlite3-dev sqlite3 libxml2-dev \
libxslt-dev autoconf libc6-dev libgdbm-dev ncurses-dev automake libtool pkg-config \
libffi-dev libv8-dev  imagemagick libmagickwand-dev fail2ban ruby-mysql screen \
mariadb-client letsencrypt unattended-upgrades

echo -e "APT::Periodic::Update-Package-Lists \"1\";\nAPT::Periodic::Unattended-Upgrade \"1\";\n" > /etc/apt/apt.conf.d/20auto-upgrades
/etc/init.d/unattended-upgrades restart

# setup user
useradd coyote -m
cp .ssh/authorized_keys /home/coyote/.ssh/
chown coyote:coyote /home/coyote/.ssh/authorized_keys
su coyote; cd 

# setup ssh for self deploys
ssh-keygen -f ~/.ssh/id_rsa -t rsa -N ''
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

# create directory for capistrano deploys
cd
mkdir data 

# rbenv tools
git clone git://github.com/sstephenson/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
echo 'eval "$(rbenv init -)"' >> ~/.bash_profile
git clone git://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bash_profile
source ~/.bash_profile

# create directory for self deploys
mkdir code
cd code
git clone https://github.com/coyote-team/coyote.git

# install ruby and gems
cd coyote
RUBY_VERSION=$(cat .ruby_version)
rbenv install -v $RUBY_VERSION
rbenv global $RUBY_VERSION
echo "gem: --no-document" > ~/.gemrc
gem install bundler
bundle install

# create .env files
bin/conf_creator.sh .env
bin/conf_creator.sh .env.production

# back to root
exit

# read env vars
source /home/coyote/code/coyote/.env
source /home/coyote/code/coyote/.env.production

# create database
SQL="create database ${DATABASE_NAME}; ALTER DATABASE ${DATABASE_NAME} charset=utf8; CREATE USER ${DATABASE_USERNAME}@${DATABASE_HOST} IDENTIFIED BY '${DATABASE_PASSWORD}'; grant all on ${DATABASE_NAME}.* to ${DATABASE_USERNAME}@${DATABASE_HOST}; use mysql; flush privileges;"
mysql -uroot -e "${SQL}"

# setup ssl
service nginx stop
letsencrypt certonly --standalone -d $HOST -t --email $SUPPORT_EMAIL --agree-tos 

# nginx
sed s/HOST/$HOST/g /home/coyote/code/coyote/config/nginx.coyote.conf > /etc/nginx/sites-available/nginx.coyote.conf
ln -s /etc/nginx/sites-available/nginx.coyote.conf /etc/nginx/sites-enabled/
rm /etc/nginx/sites-available/default

service nginx restart
echo "127.0.0.1       " $HOST >> /etc/hosts

#logrotate
LOG_CONFIG= << EOF
/home/coyote/data/coyote/current/log/*.log{
    daily
    missingok
    rotate 7
    compress
    delaycompress
    notifempty
    copytruncate
}
EOF
echo $LOG_CONFIG > /etc/logrotate.conf
echo "Install completed!"

# deploy
su coyote
source ~/.bash_profile
cd ~/code/coyote
bundle exec cap production deploy

# seed
source /home/coyote/code/coyote/.env
source /home/coyote/code/coyote/.env.production
# TODO sed to change the default user and admin credentials first in db/seeds.rb
TASK="db:seed" bundle exec cap production rake
exit
echo "Deploy and seed completed!"
