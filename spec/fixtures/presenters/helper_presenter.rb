class HelperPresenter < Rectify::Presenter
  def user_name
    current_user[:name]
  end
end
