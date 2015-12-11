class ContactForm < Rectify::Form
  attribute :name,   String
  attribute :number, String

  validates :name, :presence => true
end
