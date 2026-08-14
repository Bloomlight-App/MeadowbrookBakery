require "bridgetown"

Bridgetown.load_tasks

# Run rake without specifying any command to execute a deploy build by default.
task default: :deploy

#
# Standard set of tasks, which you can customize if you wish:
#
desc "Build the Bridgetown site for deployment"
task :deploy => [:clean, "frontend:build"] do
  Bridgetown::Commands::Build.start
end

desc "Build the site, then the baseline variant alongside it under /baseline"
task :deploy_with_baseline => :deploy do
  # A separate process on purpose: the configuration is read once per boot, and
  # the baseline needs its own base_path and destination.
  sh "BLOOMLIGHT_BASELINE=1 bin/bridgetown build"
  # esbuild writes the bundles straight into output/_bridgetown rather than
  # through the Bridgetown build, so the baseline's copy has to be put under
  # its own base_path by hand.
  cp_r "output/_bridgetown", "output/baseline/"
end

desc "Build the site in a test environment"
task :test do
  ENV["BRIDGETOWN_ENV"] = "test"
  Bridgetown::Commands::Build.start
end

require "minitest/test_task"
Minitest::TestTask.create(:test) do |t| # add on to the test task
  t.warning = false
end

desc "Runs the clean command"
task :clean do
  Bridgetown::Commands::Clean.start
end

namespace :frontend do
  desc "Build the frontend with esbuild for deployment"
  task :build do
    sh "npm run esbuild"
  end

  desc "Watch the frontend with esbuild during development"
  task :dev do
    sh "npm run esbuild-dev"
  rescue Interrupt
  end
end

#
# Add your own Rake tasks here! You can use `environment` as a prerequisite
# in order to write automations or other commands requiring a loaded site.
#
# task :my_task => :environment do
#   puts site.root_dir
#   automation do
#     say_status :rake, "I'm a Rake tast =) #{site.config.url}"
#   end
# end
