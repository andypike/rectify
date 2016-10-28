class BeforeValidationForm < Rectify::Form
  attribute :email

  validates :email, :presence => true

  def before_validation
    self.email = "default@here.com" if email.blank?
  end
end
