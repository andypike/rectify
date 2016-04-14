module Rectify
  class NullQuery < Query
    def merge(query)
      query
    end

    def query
      []
    end
  end
end
