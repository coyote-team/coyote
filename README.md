Coyote
====

[![Travis CI](https://travis-ci.org/coyote-team/coyote.svg?branch=master)](https://travis-ci.org/coyote-team/coyote)
[![Code Climate](https://codeclimate.com/github/coyote-team/coyote/badges/gpa.svg)](https://codeclimate.com/github/coyote-team/coyote)
[![Test Coverage](https://codeclimate.com/github/coyote-team/coyote/badges/coverage.svg)](https://codeclimate.com/github/coyote-team/coyote/coverage)

An open source image annotation app and API to enable the distributed annotation of museum images. Coyote is built on [Ruby-on-Rails](http://rubyonrails.org/) with MySQL (via MariaDB).  

The software was developed by the [Museum of Contemporary Art Chicago](https://mcachicago.org/) to support a distributed workflow for describing their images and publishing those descriptions to the web. 
See [coyote.pics](https://coyote.pics/) for an example annotation.

Coyote offers role-based logins to facilitate image description tasks. Administrators approve, assign, and review descriptions. Cataloguers create descriptions from an assignment queue or select images to describe. 
To provide additional context for cataloguers, Coyote presents the image caption, where available. Coyote allows multiple cataloguers to describe an image; it also allows a single cataloguer to create multiple description– potentially in multiple languages –of the same image.

More information about image description projects at the MCA and elsewhere is available at [coyote.pics](http://coyote.pics), along with contact information for the project team. You can also view or hear image descriptions on the [MCA website](http://mcachicago.org).

## Developer Setup

```bash
# installs gems, walks you through setting .env variables, creates databases, and adds seed data
bin/setup
bin/rails server && open http://localhost:3000
```

The [seed script](https://github.com/coyote-team/coyote/blob/master/db/seeds.rb) builds a simple user, so you can login as `user@example.com`.

## Documentation

Our YARD documentation is hosted at [coyote-team.github.io][https://coyote-team.github.io/coyote/].

## Usage 

```bash
# Run the server
bin/rails s

# Automatically run tests as you work. You might need to install a shim for guard.
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
bundle exec guard

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

## Heroku Deployment

Requires installation of [Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli).

```bash
git clone https://github.com/coyote-team/coyote.git
cd coyote

heroku whoami # ensure you are logged-in
heroku apps:create --name example-coyote-app-name

# This line adds a free MySQL database to your app. They may still require you to enter a credit card before allowing this step.
heroku addons:create jawsdb --as DATABASE --name coyote-production-mysql-db

# this just runs "git push heroku", but we'll be adding bells and whistles
# The first time you run this, it will take a while to install gems and prepare the environment
bin/rake deploy 

# Prepare the production database
heroku run bin/rake db:schema:load db:migrate

# adds Metum, Group, and Status objects to start you off
heroku run bin/rake coyote:db:start

# setup the first user, will prompt you for a password
heroku run bin/rake coyote:admin:create[user@example.com] 

# Configure the app to respond to your host name; requires you to create a DNS CNAME entry
domains:add coyote.example.com

# Workflow
heroku open              # opens the app in your browser
heroku ps                # displays list of active processes, corresponding to contents of Procfile
herou logs --tail        # watch application log stream
heroku run rails console # access production console
```

## Docker Setup

The app can run in a self-contained environment, which you can use for development.

First, install [Docker Community Edition](https://www.docker.com/get-docker). Then:

```bash
docker-compose build # downloads images, builds containers
docker-compose up    # start running containers
docker-compose exec web bin/rake db:setup db:migrate db:seed                    # prepare database, add seed data
docker-compose exec web bin/rake coyote:admin:create[user@example.com,password] # create initial user
```

The app should then be accessible at http://localhost:3000/. For more details see [local development with Docker Compose](https://devcenter.heroku.com/articles/local-development-with-docker-compose).

## Docker Workflow

```bash
docker ps                                 # list running containers
docker-compose build                      # rebuild web container when new gems are installed
docker-compose exec web pumactl restart   # restart Puma
docker-compose exec web bin/rails console # access Rails console
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

- [Coyote repo](http://github.com/coyote-team/coyote)
- [Coyote.pics](https://coyote.pics/)
- [Museum of Contemporary Art Chicago's Coyote](http://coyote.mcachicago.org)
- [Museum of Contemporary Art Chicago](http://www2.mcachicago.org/) 

More info regarding accessibility:

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
- Mike Subelsky, [subelsky.com](http://subelsky.com) - development

## License
[MPLv2](http://choosealicense.com/licenses/mpl-2.0/#)
