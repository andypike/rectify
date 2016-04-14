require "rspec/expectations"

RSpec::Matchers.define :make_database_queries_of do |expected|
  supports_block_expectations

  queries = []

  match do |proc|
    ActiveSupport::Notifications
      .subscribe("sql.active_record") do |_, _, _, _, query|
        sql = query[:sql]

        unless Rectify::RSpec::DatabaseReporter::SQL_TO_IGNORE.match(sql)
          queries << sql
        end
      end

    proc.call

    queries.size == expected
  end

  failure_message do |_|
    all_queries = queries.join("\n")

    "expected the number of queries to be #{expected} " \
    "but there were #{queries.size}.\n\n" \
    "Here are the queries that were made:\n\n#{all_queries}"
  end
end
