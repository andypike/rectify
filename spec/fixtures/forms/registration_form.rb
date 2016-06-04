class RegistrationForm < Rectify::Form
  attribute :email

  validates :email, presence: true
end
