COYOTE
====

[![Travis CI](https://travis-ci.org/coyote-team/coyote.svg?branch=master)](https://travis-ci.org/coyote-team/coyote)
[![Code Climate](https://codeclimate.com/github/coyote-team/coyote/badges/gpa.svg)](https://codeclimate.com/github/coyote-team/coyote)
[![Test Coverage](https://codeclimate.com/github/coyote-team/coyote/badges/coverage.svg)](https://codeclimate.com/github/coyote-team/coyote/coverage)

An open source image annotation app and API to enable the distributed annotation of museum images. Coyote is built on RubyOnRails with MySQL (via MariaDB).  

- [Coyote repo](http://github.com/coyote-team/coyote)
- [Coyote.pics](https://coyote.pics/)
- [Museum of Contemporary Art Chicago's Coyote](http://coyote.mcachicago.org)

## Developer Setup

```bash
bundle install

# Populate .env files
bin/conf_creator.sh .env # Copy this and the next one from other developers if working on an existing project
bin/conf_creator.sh .env.production
bin/conf_creator.sh .env.development
bin/conf_creator.sh .env.test

# Create the DBs for dev and test
bin/rake db:create db:migrate db:seed
RAILS_ENV=test bin/rake db:create db:migrate
```

For more information on environment or setup, see [bin/install.sh](https://github.com/coyote-team/coyote/blob/master/bin/install.sh) or the `Vagrantfile`.

Secure credentials are kept untracked in `.env` and  `.env.[development, test, staging, production]`. 

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

## Test

Lint the model factories ([more info](https://github.com/thoughtbot/factory_girl)):

```bash
bin/rake factory_girl:lint

```

Then, run the test suite:

```bash
# Once
bin/rspec

# Or dynamically via the guard daemon
guard
# Leave that running while your server is running and
# then press enter or update a page and the test suite will run

```

## Deploy

```bash
# This command will also copy your .env and .env.production to the server
bundle exec cap production deploy
```

## Update website images
This uses each website's strategy (see below)

```bash
# Update images from past 2 minutes on local
bin/rake websites:update
# Update images from past 60 minutes on local
bin/rake websites:update[60]
# Update images from past 60 minutes on production
TASK="websites:update[60]" bundle exec cap production rake

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

Assuming you are logged into an Ubuntu 16.04 LTS as a root...

You will need to set the domain name to the new IP and then to prepare the following

1. The production IP address, e.g. `173.255.234.50`
2. The new domain for coyote, e.g.  `coyote.warhol.org`.
3. The name of the hostinginstitution, e.g. The Warhol.
4. The main website address, e.g. `http://www.warhol.ora`
5. (Optional) A new Google Analytics UA identifier (for coyote UAs, click [here](https://analytics.google.com/analytics/web/#management/Settings/a86309615w128502418p132251424/)).
6. (Optional) The Rollbar access token from previous project in `.env.production`

Then you can run...

```bash
wget -qO- https://raw.githubusercontent.com/coyote-team/coyote/master/bin/install.sh | bash
```

## API

API documentation is generated at `/apipie` and you can see MCA's version  [here](http://coyote.mcachicago.org/apipie).

## Strategies
We can extend the functionality of Coyote to better integrate with your particular CMS with a strategy file.  For an example, check out [/lib/coyote/strategies/mca.rb](https://github.com/coyote-team/coyote/blob/master/lib/coyote/strategies/mca.rb) 

## Components

- [RubyOnRails](http://rubyonrails.org/)
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
  [User | id: int | first_name: string | last_name: string |  email: string | admin: bool ]
  [Image | id: int |url : string | canonical_id: string | priority: boolean | title: text | page_urls: text]
  [Tag | id: int | title: string]
  [Group | id: int | title: string]
  [Description | id: int | locale:str(en) | text: text | license:str(cc0-1.0)]
  [Website | id: int | url: string | title: string | strategy: string ]
  [Status | id: int | title: string | description: text]
  [Metum| id: int| title: string | instructions: text]

  [Assignment]->[Image]
  [Assignment]->[User]

  [Description]->[User]
  [Description]->[Metum]
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
- [ABS's Guidelines for Verbal Description](http://www.artbeyondsight.org/handbook/acs-guidelines.shtml)

## Coyote Admin
- [Rollbar](https://rollbar.com/coyote/Coyote/)
- [Google Analytics: Coyote MCA](https://analytics.google.com/analytics/web/#report/defaultid/a86309615w128502418p132251424/)

## Versus
- [Depict4](http://depictfor.us/)
- [Autotune](https://github.com/voxmedia/autotune/)

## Contributors
- Tobey Albright, [MCA Chicago](https://mcachicago.org) - graphic design
- Sina Bahram, [Prime Access Consulting](https://pac.bz/) - concept and direction
- Susan Chun, [MCA Chicago](https://mcachicago.org) - project management
- Anna Lavatelli, [MCA Chicago](https://mcachicago.org) - project management
- Christopher Reed, [SEEREAD.info](http://seeread.info) - development

## License
[MPLv2](http://choosealicense.com/licenses/mpl-2.0/#)
