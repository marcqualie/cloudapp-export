# Code Coverage
require "simplecov"
require "simplecov-lcov"
SimpleCov::Formatter::LcovFormatter.config do |c|
  c.output_directory = 'coverage' # default: "coverage/lcov"
  c.lcov_file_name = 'lcov.info' # default: "YOUR_PROJECT_NAME.lcov"
  c.report_with_single_file = true
  c.single_report_path = 'coverage/lcov.info'
end
SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new(
  [
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::LcovFormatter,
  ],
)
SimpleCov.start

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "cloudapp_export"

require "minitest/autorun"
