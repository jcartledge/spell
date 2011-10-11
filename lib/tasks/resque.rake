require "resque/tasks"
require File.dirname(__FILE__) + "/../../crawler"

namespace :resque do
  task :work    => "rake:environment"
  task :workers => "rake:environment"
end
