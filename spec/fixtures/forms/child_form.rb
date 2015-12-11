require_relative "user_form"

class ChildForm < UserForm
  mimic :user

  attribute :school, String
end
