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
      form = UserForm.from_params(params)

      expect(form).to have_attributes(
        :first_name => "Andy",
        :age        => 38,
        :colours    => %w(red blue green)
      )
    end

    it "populates the id from a params hash" do
      form = UserForm.from_params(params)

      expect(form.id).to eq(1)
    end

    it "populates nested object attributes" do
      form = UserForm.from_params(params)

      expect(form.address).to have_attributes(
        :street    => "1 High Street",
        :town      => "Wimbledon",
        :city      => "London",
        :post_code => "SW19 1AB"
      )
    end

    it "populates array attributes of objects" do
      form = UserForm.from_params(params)

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

      form = ChildForm.from_params(params)

      expect(form).to have_attributes(
        :first_name => "Andy",
        :age        => 38,
        :school     => "Rutlish"
      )
    end

    it "populates attributes from additional context data" do
      form = UserForm.from_params(params, :order_count => 10)

      expect(form.order_count).to eq(10)
    end

    it "doesn't create attributes for param data not defined in the form" do
      params["user"]["some_extra_data"] = "Some text"

      form = UserForm.from_params(params)

      expect { form.some_extra_data }.to raise_error(NoMethodError)
    end

    context "when a model is explicitally mimicked" do
      it "returns the matching model name" do
        expect(ChildForm.model_name.name).to eq("User")
      end
    end

    context "when a model is not explicitally mimicked" do
      it "uses the class name of the form minus the `Form` suffix as the model name" do
        expect(OrderForm.model_name.name).to eq("Order")
      end

      it "uses the class name of the form minus the `Form` suffix and namespace as the model name" do
        expect(Inventory::ProductForm.model_name.name).to eq("Product")
      end

      it "uses the class name of the form minus the `Form` suffix as the params key" do
        order_params = {
          "order" => {
            "number" => "12345"
          }
        }

        form = OrderForm.from_params(order_params)

        expect(form.number).to eq("12345")
      end
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

  describe "#attributes" do
    it "returns a hash of attributes with their values excluding :id" do
      form = OrderForm.new(:number => "12345", :id => 1)

      expect(form.attributes).to eq(:number => "12345")
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

  describe "#valid?" do
    describe "validating the form" do
      context "when the form has valid values" do
        it "returns true" do
          form = RegistrationForm.new(:email => "me@here.com")

          expect(form).to be_valid
        end
      end

      context "when the form has invalid values" do
        it "returns false" do
          form = RegistrationForm.new(:email => "")

          expect(form).not_to be_valid
        end
      end
    end

    describe "validating nested forms" do
      context "when the nested forms have valid values" do
        it "returns true" do
          form = SchoolForm.new(:head => TeacherForm.new(:name => "me@here.com"))

          expect(form).to be_valid
          expect(form.head).to be_valid
        end
      end

      context "when the nested forms have invalid values" do
        it "returns false" do
          form = SchoolForm.new(:head => TeacherForm.new(:name => ""))

          expect(form).not_to be_valid
          expect(form.head).not_to be_valid
        end
      end
    end

    describe "validating array attributes containing forms" do
      context "when the array of forms has valid values" do
        it "returns true" do
          form = UserForm.new(:contacts => [ContactForm.new(:name => "Andy")])

          expect(form).to be_valid
          expect(form.contacts.first).to be_valid
        end
      end

      context "when the array of forms has invalid values" do
        it "returns false" do
          form = UserForm.new(:contacts => [ContactForm.new(:name => "")])

          expect(form).not_to be_valid
          expect(form.contacts.first).not_to be_valid
        end
      end
    end
  end

  describe "#invalid?" do
    it "returns true when #valid? returns false" do
      form = RegistrationForm.new(:email => "")

      expect(form).to be_invalid
    end

    it "returns false when #valid? returns true" do
      form = RegistrationForm.new(:email => "me@here.com")

      expect(form).not_to be_invalid
    end
  end
end
