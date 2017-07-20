namespace :deploy do
  task default: %(production)

  desc "check if git is clean"
  task :check do
    if ENV.has_key?("SKIP_CLEAN_CHECK")
      puts "WARNING: Skipping git clean check"
      next
    end

    unless system("git diff --exit-code")
      abort <<-MSG
You have uncommitted changes or unpushed commits. Please stash changes or push commits before deploying!
You can disable this warning (at your peril) by running this command with SKIP_CLEAN_CHECK set to true:

SKIP_CLEAN_CHECK=true bundle exec rake deploy
MSG
    end

    unless system("git diff master..origin/master --exit-code")
      abort "You have unpushed commits. Please push your commits before deploying."
    end
  end

  desc "deploy code to production"
  task :production => :check do
    `git push heroku master`
  end
end

task deploy: %w(deploy:production)
