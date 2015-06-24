# Be sure to restart your server when you modify this file.

#if Rails.env.development?
  #Plate::Application.config.session_store :redis_store
#elsif Rails.env.production?
  #Plate::Application.config.session_store :redis_store, {
    #host: "silkroadprod.4fycam.0001.usw2.cache.amazonaws.com",
    #port: 6379,
    #expires_in: 90.minutes ,
    #namespace: 'sessions'
  #}
#else
  Plate::Application.config.session_store :cookie_store, key: '_plate_session'
#end
