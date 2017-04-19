class MyPresenterController < ActionController::Base
  include Rectify::ControllerHelpers

  def template_presenter
    present SimplePresenter.new(first_name: "Andy")
  end

  def layout_presenter
    present LayoutPresenter.new, for: :layout
  end

  def presenter_with_attribute
    present SimplePresenter.new

    expose(first_name: "Andy")
  end

  def presenter_without_attribute
    present SimplePresenter.new

    expose(last_name: "Pike")
  end

  def no_presenter
    expose(name: "Fred")
  end
end
