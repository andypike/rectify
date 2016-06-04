class HelperController < ActionController::Base
  helper_method :current_user

  private

  def current_user
    { name: "Andy" }
  end
end
