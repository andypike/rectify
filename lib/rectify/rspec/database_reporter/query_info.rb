module Rectify
  module RSpec
    class DatabaseReporter
      class QueryInfo
        def initialize(example, start, finish, query)
          @example = example
          @start   = start
          @finish  = finish
          @query   = query
        end

        def target
          return described_class.name if described_class

          root_example_group_description
        end

        def time
          finish.to_f - start.to_f
        end

        def type
          return example.metadata[:type] unless described_class

          described_class <= Rectify::Query ? :query : :unit
        end

        def ignore?
          SQL_TO_IGNORE.match(query[:sql]) || example.blank?
        end

        private

        attr_reader :example, :start, :finish, :query

        def described_class
          example.metadata[:described_class]
        end

        def root_example_group_description
          example.example_group.parent_groups.last.description
        end
      end
    end
  end
end
