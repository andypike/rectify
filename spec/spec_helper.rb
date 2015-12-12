require File.expand_path("../../lib/rectify", __FILE__)

require "rspec/collection_matchers"
require "wisper/rspec/matchers"
require "awesome_print"
require "pry"

Dir["spec/support/**/*.rb"].each  { |f| require File.expand_path(f) }
Dir["spec/fixtures/**/*.rb"].each { |f| require File.expand_path(f) }

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.disable_monkey_patching!
  config.backtrace_exclusion_patterns << /gems/
  config.order = "random"

  config.include Wisper::RSpec::BroadcastMatcher
end
