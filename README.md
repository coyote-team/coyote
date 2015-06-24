COYOTE
====
## Description

Image annotation site and API to enable the distributed annotation of museum images.

## Versus

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
    bin/rake db:create #implied development environment
    RAILS_ENV=test bin/rake db:create

    #on first use
    grep -rn HERE ./ #check for configs

Secure creds are kept untracked in ```.env```

## Scaffolds
 
##Links

- [MCA Coyote Repo](https://github.com/mcachicago/coyote)
- [Museum of Contemporary Art Chicago](http://www2.mcachicago.org/) 
- [A11Y Guidelines](http://a11yproject.com/)
- [Sina's Links on Accessibility](http://www.sinabahram.com/resources.php)

## License 
