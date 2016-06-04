class ActiveUsers < Rectify::Query
  def query
    User.where(active: true)
  end
end
