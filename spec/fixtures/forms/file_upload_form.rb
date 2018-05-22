class FileUploadForm < Rectify::Form
  mimic :user

  attribute :file, ActionDispatch::Http::UploadedFile
end
