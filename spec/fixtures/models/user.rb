class User
  include ActiveModel::Model
  include Virtus.model

  attribute :first_name, String
  attribute :age,        Integer
end
