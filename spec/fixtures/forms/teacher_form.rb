class TeacherForm < Rectify::Form
  attribute :name, String

  validates :name, presence: true
end
