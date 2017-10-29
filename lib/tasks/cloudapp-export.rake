require 'dotenv'
require 'json'
require 'cloudapp-export'

namespace :cloudapp do
  desc "Export data from CloudApp"
  task :export do |_t, _args|
    puts "Please use `cloudapp-export all` instead of this rake task"
  end
end
