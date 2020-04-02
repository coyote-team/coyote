# frozen_string_literal: true

namespace :cache do
  desc "Clears Rails cache"
  task clear: :environment do
    Rails.cache.clear
  end
end
