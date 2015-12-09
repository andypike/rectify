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
          "age" => "38"
        }
      }
    end

    it "populates attributes from a params hash" do
      form = UserForm.from_params(:user, params)

      expect(form).to have_attributes(
        :first_name => "Andy",
        :age => 38
      )
    end

    it "populates the id from a params hash" do
      form = UserForm.from_params(:user, params)

      expect(form.id).to eq(1)
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
end
