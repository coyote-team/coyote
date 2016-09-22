namespace :websites do
  desc "Update images and image info"
  task :update, [:minutes]  => :environment do |t, args|
    args.with_defaults(:minutes => 2)
    Rails.logger.info "Checking for images from #{args.minutes} minutes ago"
    Website.all.each do |w|
      w.strategy_update_images(args.minutes)
    end
  end

  task :patch_bulk, [:minutes]  => :environment do |t, args|
    args.with_defaults(:minutes => 2)
    Rails.logger.info "Patching images for descriptions from #{args.minutes} minutes ago"
    Website.all.each do |w|
			s = w.get_strategy
			if s
				s.patch_bulk(w, args.minutes)
			else
				Rails.logger.info "No strategy available for this description's image"
				return true
			end
    end
  end
end
