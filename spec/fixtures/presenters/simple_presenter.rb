class SimplePresenter < Rectify::Presenter
  attribute :first_name, String
  attribute :age, Integer

  def edit_link
    link_to "Edit #{first_name}", "edit.html"
  end
end
