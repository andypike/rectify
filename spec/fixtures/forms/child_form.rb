require_relative "user_form"

class ChildForm < UserForm
  mimic :user

  attribute :school, String

  validates :school, presence: true
end
