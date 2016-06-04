class AllUsers < Rectify::Query
  def query
    User.order(age: :asc)
  end
end
