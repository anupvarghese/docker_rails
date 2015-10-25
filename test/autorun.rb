require 'autotest/restart'
require "autotest/spec"

Autotest.add_hook :initialize do |at|
  at.testlib = "minitest-rails/autorun"
end

Autotest.add_hook :all_good do |at|
  system "rake rcov_info"
end if ENV['RCOV']
