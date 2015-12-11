require_relative "teacher_form"

class SchoolForm < Rectify::Form
  attribute :head, TeacherForm
end
