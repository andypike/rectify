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
end
