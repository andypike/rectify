class UsersOverUsingSql < Rectify::Query
  include Rectify::SqlQuery

  def initialize(age)
    @age = age
  end

  def model
    User
  end

  def sql
    <<~SQL
      SELECT *
      FROM users
      WHERE age > :age
      ORDER BY age ASC
    SQL
  end

  def params
    { :age => @age }
  end
end
