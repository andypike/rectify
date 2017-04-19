RSpec.describe Rectify::Presenter do
  describe ".new" do
    it "populates attributes from a string key hash" do
      presenter = SimplePresenter.new("first_name" => "Andy", "age" => 38)

      expect(presenter).to have_attributes(
        first_name: "Andy",
        age: 38
      )
    end

    it "populates attributes from a symbol key hash" do
      presenter = SimplePresenter.new(first_name: "Andy", age: 38)

      expect(presenter).to have_attributes(
        first_name: "Andy",
        age: 38
      )
    end
  end

  describe "#attach_controller" do
    context "when a controller is supplied" do
      it "delegates view helper calls to `controller#view_context`" do
        presenter = SimplePresenter.new(first_name: "Andy")
        presenter.attach_controller(EmptyController.new)

        expect(presenter.edit_link).to eq('<a href="edit.html">Edit Andy</a>')
      end

      it "returns the presenter object" do
        presenter = SimplePresenter.new(first_name: "Andy")

        expect(
          presenter.attach_controller(EmptyController.new)
        ).to eq(presenter)
      end
    end

    context "when a controller is not supplied" do
      it "uses ActionController::Base as a fallback for view helpers" do
        presenter = SimplePresenter.new(first_name: "Andy")

        expect(presenter.edit_link).to be_present
      end
    end

    context "when a controller has a helper method exposed" do
      it "can use the controllers helper" do
        presenter = HelperPresenter.new
        presenter.attach_controller(HelperController.new)

        expect(presenter.user_name).to eq("Andy")
      end

      it "errors if the fallback controller is used" do
        presenter = HelperPresenter.new

        expect { presenter.user_name }.to raise_error(NameError)
      end
    end
  end
end
