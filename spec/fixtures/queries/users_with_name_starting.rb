class UsersWithNameStarting < Rectify::Query
  def initialize(letter)
    @letter = letter
  end

  def query
    User.where("first_name like ?", name_prefix)
  end

  private

  def name_prefix
    "#{@letter}%"
  end
end
