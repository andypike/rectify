RSpec.describe Rectify::Presenter do
  describe ".new" do
    it "populates attributes from a string key hash" do
      presenter = SimplePresenter.new("first_name" => "Andy", "age" => 38)

      expect(presenter).to have_attributes(
        :first_name => "Andy",
        :age => 38
      )
    end

    it "populates attributes from a symbol key hash" do
      presenter = SimplePresenter.new(:first_name => "Andy", :age => 38)

      expect(presenter).to have_attributes(
        :first_name => "Andy",
        :age => 38
      )
    end
  end

  describe "#attach_controller" do
    let(:controller) { EmptyController.new }

    context "when a controller is supplied" do
      it "delegates view helper calls to `controller#view_context`" do
        presenter = SimplePresenter.new(:first_name => "Andy")
        presenter.attach_controller(controller)

        expect(presenter.edit_link).to eq('<a href="edit.html">Edit Andy</a>')
      end

      it "returns the presenter object" do
        presenter = SimplePresenter.new(:first_name => "Andy")

        expect(presenter.attach_controller(controller)).to eq(presenter)
      end
    end

    context "when a controller is not supplied" do
      it "uses ActionController::Base as a fallback for view helpers" do
        presenter = SimplePresenter.new(:first_name => "Andy")

        expect(presenter.edit_link).to be_present
      end
    end
  end
end
