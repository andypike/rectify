module Rectify
  module RSpec
    class DatabaseReporter
      class QueryStats
        def initialize
          @stats = Hash.new { |h, k| h[k] = [] }
        end

        def add(example, start, finish, query)
          info = QueryInfo.new(example, start, finish, query)
          return if info.ignore?

          stats[info.target] << info
        end

        def each
          stats.sort.each do |target, infos|
            yield(
              target,
              infos.first.type,
              infos.count,
              infos.sum(&:time).round(5)
            )
          end
        end

        def total_queries
          stats.values.flatten.count
        end

        def total_time
          stats.values.flatten.sum(&:time).round(5)
        end

        def longest_target
          return 0 if stats.empty?

          stats.keys.max_by(&:length).length
        end

        def empty?
          stats.empty?
        end

        private

        attr_reader :stats
      end
    end
  end
end
