COYOTE
====

[![Travis CI](https://travis-ci.org/coyote-team/coyote.svg?branch=master)](https://travis-ci.org/coyote-team/coyote)
[![Code Climate](https://codeclimate.com/github/coyote-team/coyote/badges/gpa.svg)](https://codeclimate.com/github/coyote-team/coyote)
[![Test Coverage](https://codeclimate.com/github/coyote-team/coyote/badges/coverage.svg)](https://codeclimate.com/github/coyote-team/coyote/coverage)


Image annotation site and API to enable the distributed annotation of museum images built on RubyOnRails with MySQL (via MariaDB). 

- [Coyote Repo](http://github.com/coyote-team/coyote)
- [Coyote.pics](https://coyote.pics/)
- [Coyote Tech intro](https://github.com/coyote-team/coyote/blob/master/app/views/pages/_intro.md)
- [Museum of Contemporary Art Chicago's Coyote](http://coyote.mcachicago.org)

## Setup

```bash
bundle install

# Copy up the top block .env.example to .env and populate
# Copy the bottom block of .env.example to .env.development
# Copy the bottom block of .env.example to .env.test
# Create the DBs for dev and test
bin/rake db:create db:migrate db:seed
RAILS_ENV=test bin/rake db:create db:migrate
```

Secure creds are kept untracked in `.env`

## Test

Lint the [FactoryGirls](https://github.com/thoughtbot/factory_girl)

```bash
bin/rake factory_girl:lint

```

Then, run the test suite:

```bash
# Once
bin/rspec

# Or dynamically via the guard daemon
guard
# Leave that running while you develop
# Then press enter or update a page and the test suite will run

```

## Deploy

```bash
# Copy the .env.production from the server
bundle exec cap production deploy
```

## Update website images

```bash
# Update images from past 2 minutes on local
bin/rake websites:update
# Update images from past 60 minutes on local
bin/rake websites:update[60]
# Update images from past 60 minutes on production
TASK="websites:update[60]" bundle exec cap production rake

```

## Usage 

```bash
# Run the server
bin/rails s

# Automatically run tests as you work
# You might need to install a shim for guard
guard

# Run the tests on their own
bin/rspec

# Run the console
bin/rails c
```

## Vagrant Setup

Some folks like to use an enclosed dev environment.  Here's a virtual machine dev environment that can be run with the open source engine vagrant. This approach can reduce your dev setup time.

Install [vagrant](https://www.vagrantup.com/downloads.html) and run `vagrant up`  Then, you can view the site like so:

```bash
vagrant up
ssh -N -L 3000:localhost:3000 vagrant@localhost -p 2222 
# Vagrant is the password
# In another terminal
open http://localhost:3000
```

## Server Setup

Assuming a Ubuntu 16.04 LTS distribution with a coyote user...

```bash
# We add this first repo for MariaDB (which is bit compatible with MySQL) 
sudo add-apt-repository 'deb http://nyc2.mirrors.digitalocean.com/mariadb/repo/10.0/ubuntu xenial main'
sudo apt-get update
sudo apt-get install -y --allow-unauthenticated software-properties-common
sudo apt-get install -y --allow-unauthenticated graphviz git libpq-dev gawk build-essential libreadline6-dev \
zlib1g-dev libssl-dev libyaml-dev autoconf libgdbm-dev libncurses5-dev automake libtool \
bison pkg-config libffi-dev mariadb-server libmariadbclient-dev git make gcc zlib1g-dev \
libssl-dev libreadline6-dev libxml2-dev libsqlite3-dev nginx openssl libreadline6 \
libreadline6-dev curl git-core zlib1g libyaml-dev libsqlite3-dev sqlite3 libxml2-dev \
libxslt-dev autoconf libc6-dev libgdbm-dev ncurses-dev automake libtool pkg-config \
libffi-dev libv8-dev  imagemagick libmagickwand-dev fail2ban ruby-mysql screen

sudo apt-get upgrade -y
git clone git://github.com/sstephenson/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
echo 'eval "$(rbenv init -)"' >> ~/.bash_profile
source ~/.bash_profile
git clone git://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bash_profile
source ~/.bash_profile

# Check .ruby-version to make sure the version below is up-to-date
rbenv install -v 2.3.1
rbenv global 2.3.1
echo "gem: --no-document" > ~/.gemrc
gem install bundler

# Edit config/nginx.site.conf to set the log path into the correct absolute path
# Then copy or link to your /etc/nginx/sites-available
# Then enable the site with symlink...
# From /etc/nginx/sites-available/nginx.site.conf to /etc/nginx/sites-enabled/nginx.site.conf
# Finish creating your MariaDB/MySQL database and user

# Then on your local box 
# Copy up the top block .env.example to .env and populate
# Copy the bottom block of .env.example to .env.production and populate
# Then deploy
bundle exec cap production deploy
# And seed the database
TASK="db:seed" bundle exec cap production rake

```

## Components

- [RubyOnRails](http://rubyonrails.org/)
- [accecess](http://lukyvj.github.io/accecss/)
- [MariaDB](https://mariadb.org/) 
- [rbenv](http://rbenv.org/) with [plugins](https://github.com/sstephenson/rbenv/wiki/Plugins) for gems, bundler, build, and binstubs
- [bundler](http://bundler.io/)
- [SASS](http://sass-lang.com/)
- [Coffeescript](http://coffeescript.org/)

## Data model

![Data model](datamodel.png)

For use on [nomnoml](http://www.nomnoml.com/)

```
[<frame>Coyote data model|
  [User | id: int | first_name: string | last_name: string |  email: string | admin: bool | timestamps]
  [Image | id: int |url : string | canonical_id: string | priority: boolean | title: text | page_urls: text]
  [Tag | id: int | title: string]
  [Group | id: int | title: string]
  [Description | id: int | locale:str(en) | text: text | timestamps]
  [Website | id: int | url: string | title: string | timestamps]
  [Status | id: int | title: string | description: text]
  [Meta| id: int| title: string | instructions: text]

  [Assignment]->[Image]
  [Assignment]->[User]

  [Description]->[User]
  [Description]->[Meta]
  [Description]->[Status]

  [Image]->[Group]
  [Image]->[Website]
  [Image] +-> 0..* [Description]
  [Image] +-> 0..* [Tag]
]
```

Descriptions have an audit log that tracks changes across most columns.
 
## Links

- [MCA Coyote Repo](https://github.com/mcachicago/coyote)
- [Museum of Contemporary Art Chicago](http://www2.mcachicago.org/) 
- [A11Y Guidelines](http://a11yproject.com/)
- [Sina's Links on Accessibility](http://www.sinabahram.com/resources.php)
- [ARIA in HTML](http://rawgit.com/w3c/aria-in-html/master/index.html) and [ARIA](http://www.w3.org/TR/wai-aria/states_and_properties#global_states)

## Versus
- [Depict4](http://depictfor.us/)
- [Autotune](https://github.com/voxmedia/autotune/)

## License
[MPLv2](http://choosealicense.com/licenses/mpl-2.0/#)
