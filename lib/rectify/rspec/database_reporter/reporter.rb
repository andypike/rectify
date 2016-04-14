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
