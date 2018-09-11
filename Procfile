release: if [[ $COYOTE_REVIEW_APP != "true" ]]; then bundle exec rake db:migrate; fi
web: bundle exec puma -C config/puma.rb
