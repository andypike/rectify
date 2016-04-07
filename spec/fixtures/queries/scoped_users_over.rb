class ScopedUsersOver < Rectify::Query
  def initialize(age, scope = AllUsers.new)
    @age   = age
    @scope = scope
  end

  def query
    @scope.query.where("age > ?", @age)
  end
end
