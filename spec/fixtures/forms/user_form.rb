require_relative "address_form"
require_relative "contact_form"

class UserForm < Rectify::Form
  mimic :user

  attribute :user,        String
  attribute :first_name,  String
  attribute :age,         Integer
  attribute :colours,     Array
  attribute :address,     AddressForm
  attribute :contacts,    Array[ContactForm]
  attribute :order_count, Integer
  attribute :other_id,    Integer
  attribute :last_login_date, String

  validates :first_name, :presence => true

  def map_model(model)
    self.last_login_date = model.last_logged_in.strftime("%d/%m/%Y")
  end
end
