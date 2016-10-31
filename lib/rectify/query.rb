module Rectify
  class Query
    include Enumerable

    def self.merge(*queries)
      queries.reduce(NullQuery.new) { |a, e| a.merge(e) }
    end

    def initialize(scope = ActiveRecord::NullRelation)
      @scope = scope
    end

    def query
      @scope
    end

    def |(other)
      if relation? && other.relation?
        Rectify::Query.new(cached_query.merge(other.cached_query))
      elsif eager? && other.eager?
        Rectify::Query.new(cached_query | other.cached_query)
      else
        raise UnableToComposeQueries.new(self, other)
      end
    end

    alias merge |

    def count
      cached_query.count
    end

    def first
      cached_query.first
    end

    def each(&block)
      cached_query.each(&block)
    end

    def exists?
      return cached_query.exists? if relation?

      cached_query.present?
    end

    def none?
      !exists?
    end

    def to_a
      cached_query.to_a
    end

    alias to_ary to_a

    def relation?
      cached_query.is_a?(ActiveRecord::Relation)
    end

    def eager?
      cached_query.is_a?(Array)
    end

    def cached_query
      @cached_query ||= query
    end
  end
end
