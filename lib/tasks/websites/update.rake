namespace :websites do
  desc "Update images and image info"
  task :update, [:minutes]  => :environment do |t, args|
    args.with_defaults(:minutes => 1)
    Rails.logger.info "Checking for images from #{args.minutes} minutes ago"
    Website.all.each do |w|
      w.strategy_update_images(arg.minutes)
    end
  end
end
