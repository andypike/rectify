require File.expand_path("../../lib/rectify", __FILE__)
require File.expand_path("../../lib/rectify/rspec", __FILE__)

require "rspec/collection_matchers"
require "awesome_print"
require "pry"
require "action_controller"

Dir["spec/support/**/*.rb"].each  { |f| require File.expand_path(f) }
Dir["spec/fixtures/**/*.rb"].each { |f| require File.expand_path(f) }

system("rake db:migrate")

db_config = YAML.safe_load(File.open("spec/config/database.yml"))
ActiveRecord::Base.establish_connection(db_config)

RSpec.configure do |config|
  config.expect_with(:rspec) do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with(:rspec) do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.around(:each) do |test|
    ActiveRecord::Base.transaction do
      test.run
      raise ActiveRecord::Rollback
    end
  end

  config.formatter = :documentation
  config.disable_monkey_patching!
  config.backtrace_exclusion_patterns << /gems/
  config.order = "random"

  config.include Rectify::RSpec::Helpers
end

Rectify::RSpec::DatabaseReporter.enable
