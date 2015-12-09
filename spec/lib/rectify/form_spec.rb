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
end
