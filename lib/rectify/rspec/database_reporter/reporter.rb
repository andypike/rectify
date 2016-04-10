module Rectify
  module RSpec
    class DatabaseReporter
      SQL_TO_IGNORE = /
        pg_table|
        pg_attribute|
        pg_namespace|
        current_database|
        information_schema|
        sqlite_master|
        ^TRUNCATE TABLE|
        ^ALTER TABLE|
        ^BEGIN|
        ^COMMIT|
        ^ROLLBACK|
        ^RELEASE|
        ^SAVEPOINT|
        ^SHOW|
        ^PRAGMA
      /xi

      def self.enable
        # TODO: Allow a developer to configure what they want stats on.
        # Currently we report the time taken and number of queries per type or
        # class. But we are probably more interested in stats outside of feature
        # specs and Query object specs as these are expected to have queries.
        # Other classes under test should have less queries as we should stub
        # out Query object usage which in turns means less setup of database
        # state using factories. These other classes may well require database
        # queries as they might need to confirm that database state has
        # changed correctly for example.

        ::RSpec.configure do |config|
          config.reporter.register_listener(
            Reporter.new,
            :start,
            :example_started,
            :start_dump
          )
        end
      end

      class Reporter
        def initialize
          @query_stats = QueryStats.new
        end

        def start(_)
          ActiveSupport::Notifications
            .subscribe("sql.active_record") do |_, start, finish, _, query|
              query_stats.add(current_example, start, finish, query)
            end
        end

        def example_started(notification)
          @current_example = notification.example
        end

        def start_dump(_)
          Display.new(query_stats).render
        end

        private

        attr_reader :query_stats, :current_example
      end
    end
  end
end
