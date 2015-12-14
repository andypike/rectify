class User
  include ActiveModel::Model
  include Virtus.model

  attribute :first_name, String
  attribute :age,        Integer

  def save!
    # For mocking an ActiveRecord class
  end
end
