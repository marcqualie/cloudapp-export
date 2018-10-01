require "simplecov"
SimpleCov.start

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "cloudapp_export"

require "minitest/autorun"
