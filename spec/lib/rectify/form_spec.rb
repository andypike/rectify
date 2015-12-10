RSpec.describe Rectify::Form do
  describe ".new" do
    it "populates attributes from a string key hash" do
      form = UserForm.new("first_name" => "Andy", "age" => 38)

      expect(form).to have_attributes(
        :first_name => "Andy",
        :age => 38
      )
    end

    it "populates attributes from a symbol key hash" do
      form = UserForm.new(:first_name => "Andy", :age => 38)

      expect(form).to have_attributes(
        :first_name => "Andy",
        :age => 38
      )
    end
  end

  describe ".from_params" do
    let(:params) do
      {
        "id" => "1",
        "user" => {
          "first_name" => "Andy",
          "age"        => "38",
          "colours"    => %w(red blue green),
          "address" => {
            "street"    => "1 High Street",
            "town"      => "Wimbledon",
            "city"      => "London",
            "post_code" => "SW19 1AB"
          },
          "contacts" => [
            { "name" => "Amber",   "number" => "123" },
            { "name" => "Megan",   "number" => "456" },
            { "name" => "Charlie", "number" => "789" }
          ]
        }
      }
    end

    it "populates attributes from a params hash" do
      form = UserForm.from_params(:user, params)

      expect(form).to have_attributes(
        :first_name => "Andy",
        :age        => 38,
        :colours    => %w(red blue green)
      )
    end

    it "populates the id from a params hash" do
      form = UserForm.from_params(:user, params)

      expect(form.id).to eq(1)
    end

    it "populates nested object attributes" do
      form = UserForm.from_params(:user, params)

      expect(form.address).to have_attributes(
        :street    => "1 High Street",
        :town      => "Wimbledon",
        :city      => "London",
        :post_code => "SW19 1AB"
      )
    end

    it "populates array attributes of objects" do
      form = UserForm.from_params(:user, params)

      expect(form.contacts).to have(3).items
      expect(form.contacts[0].name).to eq("Amber")
      expect(form.contacts[0].number).to eq("123")
      expect(form.contacts[1].name).to eq("Megan")
      expect(form.contacts[1].number).to eq("456")
      expect(form.contacts[2].name).to eq("Charlie")
      expect(form.contacts[2].number).to eq("789")
    end

    it "populates a derived form" do
      params["user"]["school"] = "Rutlish"

      form = ChildForm.from_params(:user, params)

      expect(form).to have_attributes(
        :first_name => "Andy",
        :age        => 38,
        :school     => "Rutlish"
      )
    end
  end

  describe ".from_model" do
    let(:model) do
      User.new(:first_name => "Andy", :age => 38)
    end

    it "populates attributes from an ActiveModel" do
      form = UserForm.from_model(model)

      expect(form).to have_attributes(
        :first_name => "Andy",
        :age => 38
      )
    end
  end

  describe ".model_name" do
    it "allows a form to mimic a model" do
      expect(UserForm.model_name.name).to eq("User")
    end
  end

  describe "#persisted?" do
    context "when the form id is a number greater than zero" do
      it "returns true" do
        form = UserForm.new(:id => 1)

        expect(form).to be_persisted
      end
    end

    context "when the form id is zero" do
      it "returns false" do
        form = UserForm.new(:id => 0)

        expect(form).not_to be_persisted
      end
    end

    context "when the form id is less than zero" do
      it "returns false" do
        form = UserForm.new(:id => -1)

        expect(form).not_to be_persisted
      end
    end

    context "when the form id is blank" do
      it "returns false" do
        form = UserForm.new(:id => nil)

        expect(form).not_to be_persisted
      end
    end
  end

  context "when being used with a form builder" do
    describe "#to_key" do
      it "returns an array containing the id" do
        form = UserForm.new(:id => 2)

        expect(form.to_key).to eq([2])
      end
    end

    describe "#to_model" do
      it "returns the form object (self)" do
        form = UserForm.new

        expect(form.to_model).to eq(form)
      end
    end
  end
end
