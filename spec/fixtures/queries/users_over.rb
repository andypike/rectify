class UsersOver < Rectify::Query
  def initialize(age)
    @age = age
  end

  def query
    User.where("age > ?", @age)
  end
end
