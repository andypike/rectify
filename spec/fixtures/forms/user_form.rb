require_relative "address_form"
require_relative "contact_form"

class UserForm < Rectify::Form
  mimic :user

  attribute :first_name,  String
  attribute :age,         Integer
  attribute :colours,     Array
  attribute :address,     AddressForm
  attribute :contacts,    Array[ContactForm]
  attribute :order_count, Integer
  attribute :other_id,    Integer
end
