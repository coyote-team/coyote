COYOTE
====

Image annotation site and API to enable the distributed annotation of museum images.

## Usage 

    #run the server
    bin/rails s

    #automatically run tests as you work
    #you might need to install a shim for guard
    guard

    #run the tests on their own
    bin/rspec

    #run the console
    bin/rails c

We could include build status here.

## Requirements

MariaDB, rbenv, ruby gems, and bundler.

## Setup

    bundle install

    #set up the .env, override at .env.development and .env.test if needed

    #create the DBs for dev and test
    bin/rake db:create db:migrate 
    RAILS_ENV=test bin/rake db:create db:migrate

Secure creds are kept untracked in ```.env```

##Data model

For use on [nomnoml](http://www.nomnoml.com/)

    [<frame>Coyote data model|
      [User | id: int | email: string | admin: bool | timestamps]
      [Image | id: int |url : string]
      [Tag | id: int | title: string]
      [Group | id: int | title: string]
      [Description | id: int | locale:str(en) | text: text | timestamps]
      [Website | id: int | url: string | title: string | timestamps]
      [Status | id: int | title: string | description: text]
      [Meta| id: int| title: string | instructions: text]

      [Website]->[Group]
      [Image]->[Group]
      [Description]->Assigned[User]
      [Description]->Assigner[User]
      [Description]->[Meta]
      [Description]->[Status]

      [Image] +-> 0..* [Description]
      [Image] +-> 0..* [Tag]
    ]


## Scaffolds

First we initialized our generators and our user login  system.

    rails g bootstrap:install --template-engine=haml
    rails g devise:install
    rails g devise user 
    rails g devise:views users
    #https://github.com/plataformatec/devise
    rake acts_as_taggable_on_engine:install:migrations
    #https://github.com/mbleigh/acts-as-taggable-on

Then we generated our scaffolds

    rails g pizza_scaffold website title:string url:string  --force
    rails g pizza_scaffold image url:string website:references --force
    rails g pizza_scaffold group title:string --force
    rails g pizza_scaffold status title:string description:text --force
    rails g pizza_scaffold meta title:string instructions:text --force
    rails g pizza_scaffold description locale:string text:text status:references image:references metum:references --force
    rails g migration AddAdminBooleanToUsers admin:boolean --force
    #set en default for locale
    #http://stackoverflow.com/questions/13464277/rails-how-to-use-language-list-gem-with-select-tag-in-a-form
    #set admin bool on user, default false

For updating generator based views and controllers

    rails g pizza_controller website title:string url:string  --force
    rails g pizza_controller image url:string website:references --force
    rails g pizza_controller group title:string --force
    rails g pizza_controller status title:string description:text --force
    rails g pizza_controller meta title:string instructions:text --force
    rails g pizza_controller description locale:string text:text status:references image:references metum:references --force
 
##Links

- [MCA Coyote Repo](https://github.com/mcachicago/coyote)
- [Museum of Contemporary Art Chicago](http://www2.mcachicago.org/) 
- [A11Y Guidelines](http://a11yproject.com/)
- [Sina's Links on Accessibility](http://www.sinabahram.com/resources.php)
- [ARIA in HTML](http://rawgit.com/w3c/aria-in-html/master/index.html) and [ARIA](http://www.w3.org/TR/wai-aria/states_and_properties#global_states)

## Versus

## License 
