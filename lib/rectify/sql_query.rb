module Rectify
  module SqlQuery
    def query
      model.find_by_sql([sql, params])
    end
  end
end
