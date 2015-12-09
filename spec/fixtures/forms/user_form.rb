class UserForm < Rectify::Form
  route_as :user

  attribute :first_name, String
  attribute :age,        Integer
  attribute :colours,    Array
  attribute :address,    AddressForm
end
