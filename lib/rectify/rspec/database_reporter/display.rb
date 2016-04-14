module Rectify
  module RSpec
    class DatabaseReporter
      class Display
        def initialize(query_stats)
          @query_stats = query_stats
        end

        def render
          return if query_stats.empty?

          header
          rows
          summary
        end

        private

        attr_reader :query_stats

        def target_length
          query_stats.longest_target
        end

        def header
          puts ""
          puts headers
          puts "-" * headers.length
        end

        def headers
          target_header  = "Target".ljust(target_length)
          type_header    = "Type".ljust(10)
          queries_header = "Queries".rjust(7)
          time_header    = "Time (s)".rjust(7)

          "#{target_header} | " \
          "#{type_header} | " \
          "#{queries_header} | " \
          "#{time_header}"
        end

        def rows
          query_stats.each do |target, type, count, time|
            puts(
              "#{target.ljust(target_length)} | " \
              "#{type.to_s.ljust(10)} | " \
              "#{count.to_s.rjust(7)} | " \
              "#{time.to_s.rjust(7)}"
            )
          end
        end

        def summary
          puts ""
          puts "Database Queries: #{query_stats.total_queries} "\
               "in #{query_stats.total_time}s"
        end
      end
    end
  end
end
