RSpec.describe Rectify::Controller do
  let(:controller)   { MyPresenterController.new }
  let(:view_context) { controller.view_context }

  describe "#present" do
    it "gives the presnter access to the `view_context`" do
      controller.template_presenter

      expect(view_context.presenter.edit_link).to be_present
    end

    it "makes the Presenter accessible in the view via `presenter`" do
      controller.template_presenter

      expect(view_context.presenter).to be_a(SimplePresenter)
    end

    it "allows for other Presenters by arbitrary key" do
      controller.layout_presenter

      expect(view_context.presenter(:layout)).to be_a(LayoutPresenter)
    end
  end

  describe "#expose" do
    context "when there is a presenter with the attribute" do
      it "sets the attribute value on the presenter" do
        controller.presenter_with_attribute

        expect(view_context.presenter.first_name).to eq("Andy")
      end
    end

    context "when there is a presenter without the attribute" do
      it "sets the attribute value on the presenter" do
        controller.presenter_without_attribute

        expect(view_context.instance_variable_get("@last_name")).to eq("Pike")
      end
    end

    context "when there isn't a presenter" do
      it "sets the attribute value on the presenter" do
        controller.no_presenter

        expect(view_context.instance_variable_get("@name")).to eq("Fred")
      end
    end
  end
end
