# Coyote

[![Travis CI](https://travis-ci.org/coyote-team/coyote.svg?branch=master)](https://travis-ci.org/coyote-team/coyote)
[![Code Climate](https://codeclimate.com/github/coyote-team/coyote/badges/gpa.svg)](https://codeclimate.com/github/coyote-team/coyote)
[![Test Coverage](https://codeclimate.com/github/coyote-team/coyote/badges/coverage.svg)](https://codeclimate.com/github/coyote-team/coyote/coverage)

An open source image annotation app enabling the distributed annotation and comprehensive representation of images. Long descriptions can range from one sentence to several paragraphs. The software was developed by the [Museum of Contemporary Art Chicago](https://mcachicago.org/) to support a distributed workflow for describing their images and publishing those descriptions to the web. 

## Example

An image like this would traditionally be described by [alt text](https://en.wikipedia.org/wiki/Alt_attribute) like <q>A red, white, and blue fabric canopy presses against walls of room; portable fans blow air into the room through a doorway.</q>: 

![MCAChicago sample image T.Y.F.F.S.H](doc_assets/mca_sample.png "A red, white, and blue fabric canopy presses against walls of room; portable fans blow air into the room through a doorway.")

*Kris Martin, Belgian, b. 1972. T.Y.F.F.S.H., 2011. Collection: Museum of Contemporary Art. Photo: Nathan Keay, © MCA Chicago.*

Coyote aims to provide more comprehensive representations:

> This is an installation that viewers are invited to walk inside of. From this viewpoint you are looking through a doorway at a slight distance, as if standing inside of a large cave and looking out of its narrow entrance at the world outside. 
> The walls of this cave are alternating stripes of red, white, and blue material that seems to be made of some kind of thin fabric. These colored stripes spiral around toward the entrance, as if being sucked out of the opening. 
> The inside of the cave is more shadowed and the area outside is brightly lit. Gradually you notice that there are in fact two openings lined up in front of each other, straight ahead of you: the first one is a tall rectangle—the red, white and blue 
> fabric is wrapped through the edges of a standard doorway; beyond that it continues to spiral around toward another circular opening. The center of this circle is much brighter, as if one had finally escape from the cave. 
> At the center of that circular opening you see two large white fans facing your direction, blowing air into the cave-like opening. Beyond the fans you see a brown, square form, which is the bottom of a huge wicker basket. 
> This basket, lying on its side, helps to reveal the truth about what you are seeing: You are standing inside of a huge hot air balloon, which is lying on its side. Blown by the fans, the fabric billows out to press out against the existing w
> alls of a large room, the malleable shape of the balloon conforming to the rectangular surfaces of an existing building–the gallery that contains it.

More information about image description projects at the MCA and elsewhere is available at [coyote.pics](http://coyote.pics), along with contact information for the project team. You can also view or hear image descriptions on the [MCA website](http://mcachicago.org).

## Table of contents

- [Developer Setup](#developer-setup)
- [Documentation](#documentation)
- [Heroku Deployment](#heroku-deployment)
- [API](#api)
- [Strategies](#strategies)
- [Data Model](#data-model)
- [Links](#links)
- [Contributors](#contributors)
- [License](#license)

## <a name="developer-setup"></a>Developer Setup 

_Beginning Developers_

The app can run in a self-contained Docker container, which you can use for development. For more details see [local development with Docker Compose](https://devcenter.heroku.com/articles/local-development-with-docker-compose).

1) Install [Docker Community Edition](https://www.docker.com/get-docker)

2) Run the following commands:

```bash
git clone https://github.com/coyote-team/coyote.git
cd coyote
docker-compose build # downloads images, builds containers
docker-compose up    # start running containers
docker-compose exec web bin/rake db:setup db:migrate db:seed                    # prepare database, add seed data
docker-compose exec web bin/rake coyote:admin:create[user@example.com,password] # create initial user
```

3) Open `http://localhost:3000` in your browser.

Once the app is running you can interact with it using commands like this:

```bash
docker ps                                 # list running containers
docker-compose build                      # rebuild web container when new gems are installed
docker-compose exec web pumactl restart   # restart Puma
docker-compose exec web bin/rails console # access Rails console
```

_Experienced Developers_

The app can also run in your local development environment, but requires a bit more know-how.

1) [Install Postgres](https://www.postgresql.org/) (on MacOS try [Postgres.app](http://postgresapp.com/)).

2) Run the following commands:

```bash
git clone https://github.com/coyote-team/coyote.git
cd coyote
bin/setup
bin/rails server && open http://localhost:3000
```

The [seed script](https://github.com/coyote-team/coyote/blob/master/db/seeds.rb) builds a simple user, so you can login as `user@example.com`.

We have setup a `Guardfile` to speed up development. Try `bundle exec guard`.

## <a name="documentation"></a> Documentation

YARD documentation is hosted at [coyote-team.github.io](https://coyote-team.github.io/coyote/).

## <a name="heroku-deployment"> Heroku Deployment

Requires installation of [Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli).

```bash
git clone https://github.com/coyote-team/coyote.git
cd coyote

heroku whoami # ensure you are logged-in
heroku apps:create --name example-coyote-app-name

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

## <a name="api"> API

API documentation is generated at `/apipie` and you can see MCA's version  [here](http://coyote.mcachicago.org/apipie).

## <a name="strategies"> Strategies

We can extend the functionality of Coyote to better integrate with your particular CMS with a strategy file. For an example, check out [/lib/coyote/strategies/mca.rb](https://github.com/coyote-team/coyote/blob/master/lib/coyote/strategies/mca.rb).

## <a name="data-mode"> Data Model

![Data model diagram](doc_assets/datamodel.png "An entity-relationship diagram demonstrating belongs-to/has-many relationships between database tables with connecting arrows")

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
 
## <a name="links"> Links

- [Coyote repo](http://github.com/coyote-team/coyote)
- [Coyote.pics](https://coyote.pics/)
- [Museum of Contemporary Art Chicago's Coyote](http://coyote.mcachicago.org)
- [Museum of Contemporary Art Chicago](http://www2.mcachicago.org/) 

More info regarding accessibility:

- [A11Y Guidelines](http://a11yproject.com/)
- [Sina's Links on Accessibility](http://www.sinabahram.com/resources.php)
- [ARIA in HTML](http://rawgit.com/w3c/aria-in-html/master/index.html) and [ARIA](http://www.w3.org/TR/wai-aria/states_and_properties#global_states)
- [ABS's Guidelines for Verbal Description](http://www.artbeyondsight.org/handbook/acs-guidelines.shtml)

## <a name="contributors"> Contributors

- Tobey Albright, [MCA Chicago](https://mcachicago.org) - graphic design
- Sina Bahram, [Prime Access Consulting](https://pac.bz/) - concept and direction
- Susan Chun, [MCA Chicago](https://mcachicago.org) - project management
- Anna Lavatelli, [MCA Chicago](https://mcachicago.org) - project management
- Christopher Reed, [SEEREAD.info](http://seeread.info) - development
- Mike Subelsky, [subelsky.com](http://subelsky.com) - development

## <a name="license"> License

[MPLv2](http://choosealicense.com/licenses/mpl-2.0/#)
