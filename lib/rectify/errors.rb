module Rectify
  class UnableToComposeQueries < StandardError
    def initialize(query, other)
      super(
        "Unable to composite queries #{query.class.name} and " \
        "#{other.class.name}. You cannot compose queries where #query " \
        "returns an ActiveRecord::Relation in one and an array in the other."
      )
    end
  end
end
