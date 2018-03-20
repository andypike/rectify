require_relative "phone_form"

class ContactForm < Rectify::Form
  attribute :name,   String
  attribute :number, String
  attribute :phones, Array[PhoneForm]

  validates :name, :presence => true
end
