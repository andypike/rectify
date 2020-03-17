RSpec.describe Rectify::Form do
  describe ".new" do
    it "populates attributes from a string key hash" do
      form = UserForm.new(
        "user" => "andy38",
        "first_name" => "Andy",
        "age" => 38
      )

      expect(form).to have_attributes(
        :user       => "andy38",
        :first_name => "Andy",
        :age => 38
      )
    end

    it "populates attributes from a symbol key hash" do
      form = UserForm.new(:user => "andy38", :first_name => "Andy", :age => 38)

      expect(form).to have_attributes(
        :user       => "andy38",
        :first_name => "Andy",
        :age => 38
      )
    end
  end

  describe ".from_params" do
    let(:params) do
      ActionController::Parameters.new(
        "id"       => "1",
        "other_id" => "2",
        "user" => {
          "user"       => "andy38",
          "first_name" => "Andy",
          "age"        => "38",
          "colours"    => %w[red blue green],
          "file"       => ActionDispatch::Http::UploadedFile.new(:tempfile => Tempfile.new("file")),
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
      )
    end

    it "populates attributes from a params hash" do
      form = UserForm.from_params(params)

      expect(form).to have_attributes(
        :user       => "andy38",
        :first_name => "Andy",
        :age        => 38,
        :colours    => %w[red blue green]
      )
    end

    it "populates the id from a params hash" do
      form = UserForm.from_params(params)

      expect(form.id).to eq(1)
    end

    it "populates other root level values from a params hash" do
      form = UserForm.from_params(params)

      expect(form.other_id).to eq(2)
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

    it "converts param keys with dashes to underscores" do
      params = ActionController::Parameters.new(
        "first-name" => "Andy",
        "address" => {
          "post-code" => "SW19 1AB"
        }
      )

      form = UserForm.from_params(params)

      expect(form.first_name).to eq("Andy")
      expect(form.address.post_code).to eq("SW19 1AB")
    end

    it "populates an indexed array of attributes" do
      params = ActionController::Parameters.new(
        "user" => {
          "contacts" => {
            "0" => { "name" => "Amber",   "number" => "123" },
            "1" => { "name" => "Megan",   "number" => "456" },
            "2" => { "name" => "Charlie", "number" => "789" }
          }
        }
      )

      form = UserForm.from_params(params)

      expect(form.contacts).to have(3).items
      expect(form.contacts[0].name).to eq("Amber")
      expect(form.contacts[0].number).to eq("123")
      expect(form.contacts[1].name).to eq("Megan")
      expect(form.contacts[1].number).to eq("456")
      expect(form.contacts[2].name).to eq("Charlie")
      expect(form.contacts[2].number).to eq("789")
    end

    it "populates nested indexed arrays of array attributes" do
      params = ActionController::Parameters.new(
        "user" => {
          "contacts" => {
            "0" => {
              "name" => "Amber",
              "number" => "123",
              "phones" => {
                "0" => { "number" => "111111111", "country_code" => "+34" },
                "1" => { "number" => "222222222", "country_code" => "+34" }
              }
            },
            "1" => { "name" => "Megan", "number" => "456" }
          }
        }
      )

      form = UserForm.from_params(params)

      expect(form.contacts).to have(2).items
      expect(form.contacts[0].name).to eq("Amber")
      expect(form.contacts[0].number).to eq("123")
      expect(form.contacts[0].phones[0].number).to eq("111111111")
      expect(form.contacts[0].phones[0].country_code).to eq("+34")
      expect(form.contacts[0].phones[1].number).to eq("222222222")
      expect(form.contacts[0].phones[1].country_code).to eq("+34")
      expect(form.contacts[1].name).to eq("Megan")
      expect(form.contacts[1].number).to eq("456")
    end

    it "populates nested indexed arrays of nested form attributes" do
      params = ActionController::Parameters.new(
        "user" => {
          "primary_contact" => {
            "name" => "Amber",
            "number" => "123",
            "phones" => {
              "0" => { "number" => "111111111", "country_code" => "+34" },
              "1" => { "number" => "222222222", "country_code" => "+34" }
            }
          }
        }
      )

      form = UserForm.from_params(params)

      expect(form.primary_contact.name).to eq("Amber")
      expect(form.primary_contact.number).to eq("123")
      expect(form.primary_contact.phones[0].number).to eq("111111111")
      expect(form.primary_contact.phones[0].country_code).to eq("+34")
      expect(form.primary_contact.phones[1].number).to eq("222222222")
      expect(form.primary_contact.phones[1].country_code).to eq("+34")
    end

    it "populates a derived form" do
      params["user"]["school"] = "Rutlish"

      form = ChildForm.from_params(params)

      expect(form).to have_attributes(
        :user       => "andy38",
        :first_name => "Andy",
        :age        => 38,
        :school     => "Rutlish"
      )
    end

    it "populates attributes from additional context data" do
      form = UserForm.from_params(params, :order_count => 10)

      expect(form.order_count).to eq(10)
    end

    it "populates uploaded file attributes" do
      form = FileUploadForm.from_params(params)

      expect(form.file).to be_present
    end

    it "doesn't create attributes for param data not defined in the form" do
      params["user"]["some_extra_data"] = "Some text"

      form = UserForm.from_params(params)

      expect { form.some_extra_data }.to raise_error(NoMethodError)
    end
  end

  describe ".from_model" do
    let(:model) do
      User.new(
        :user       => "andy38",
        :first_name => "Andy",
        :age        => 38,
        :contacts   => [
          Contact.new(:name => "James", :number => "12345")
        ],
        :address => Address.new(
          :street    => "1 High Street",
          :town      => "Wimbledon",
          :city      => "London",
          :post_code => "SW19 1AB"
        ),
        :last_logged_in => Time.new(2016, 1, 30, 9, 30, 0)
      )
    end

    it "populates attributes from an ActiveModel" do
      form = UserForm.from_model(model)

      expect(form).to have_attributes(
        :user       => "andy38",
        :first_name => "Andy",
        :age => 38
      )
    end

    it "populates attributes from a model with a has_many" do
      form = UserForm.from_model(model)

      expect(form.contacts).to have(1).item
      expect(form.contacts.first).to have_attributes(
        :name   => "James",
        :number => "12345"
      )
    end

    it "populates attributes from a model with a belongs_to" do
      form = UserForm.from_model(model)

      expect(form.address).to have_attributes(
        :street    => "1 High Street",
        :town      => "Wimbledon",
        :city      => "London",
        :post_code => "SW19 1AB"
      )
    end

    it "populates form via custom mapping logic (via #map_model)" do
      form = UserForm.from_model(model)

      expect(form.last_login_date).to eq("30/01/2016")
    end
  end

  describe ".from_json" do
    it "populates attributes from a json string" do
      json = <<-JSON
        {
          "user": "andy38",
          "first_name": "Andy",
          "age": 38,
          "address": {
            "street": "1 High Street"
          },
          "contacts": [
            { "name": "James" }
          ]
        }
      JSON

      form = UserForm.from_json(json)

      expect(form).to have_attributes(
        :user       => "andy38",
        :first_name => "Andy",
        :age => 38
      )
      expect(form.address.street).to eq("1 High Street")
      expect(form.contacts.first.name).to eq("James")
    end
  end

  describe ".model_name" do
    context "when a model is explicitally mimicked" do
      it "returns the matching model name" do
        expect(ChildForm.model_name.name).to eq("User")
      end
    end

    context "when a model is not explicitally mimicked" do
      it "returns the class name minus the `Form` suffix" do
        expect(OrderForm.model_name.name).to eq("Order")
      end

      it "returns the class name minus the `Form` suffix and namespace" do
        expect(Inventory::ProductForm.model_name.name).to eq("Product")
      end
    end

    it "uses the class name minus the `Form` suffix as the params key" do
      order_params = {
        "order" => {
          "number" => "12345"
        }
      }

      form = OrderForm.from_params(order_params)

      expect(form.number).to eq("12345")
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

  describe "#attributes_with_values" do
    it "returns a hash of attributes where their values are non-nil" do
      form = AddressForm.new(
        :id        => 1,
        :street    => "1 High Street",
        :town      => nil,
        :post_code => "GU1 2AB"
      )

      expect(form.attributes_with_values).to eq(
        :street    => "1 High Street",
        :post_code => "GU1 2AB"
      )
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

    describe "#before_validation" do
      it "calls #before_validation before validations are run" do
        form = BeforeValidationForm.new(:email => "")

        expect(form).to be_valid
        expect(form.email).to eq("default@here.com")
      end
    end

    describe "validating derived forms" do
      context "when the form and the super class are valid" do
        it "returns true" do
          form = ChildForm.new(:school => "High School", :first_name => "Andy")

          expect(form).to be_valid
          expect(form.errors[:school]).not_to be_present
          expect(form.errors[:first_name]).not_to be_present
        end
      end

      context "when the form is valid but the super class is invalid" do
        it "returns false" do
          form = ChildForm.new(:school => "High School", :first_name => "")

          expect(form).not_to be_valid
          expect(form.errors[:school]).not_to be_present
          expect(form.errors[:first_name]).to be_present
        end
      end

      context "when the form and the super class are invalid" do
        it "returns false" do
          form = ChildForm.new(:school => "", :first_name => "")

          expect(form).not_to be_valid
          expect(form.errors[:school]).to be_present
          expect(form.errors[:first_name]).to be_present
        end
      end
    end

    describe "validating nested forms" do
      context "when the nested forms have valid values" do
        it "returns true" do
          form = SchoolForm.new(
            :head => TeacherForm.new(:name => "me@here.com")
          )

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

      context "when ignoring nested forms with invalid values" do
        it "returns true" do
          form = SchoolForm.new(:head => TeacherForm.new(:name => ""))

          expect(form).to be_valid(:exclude_nested => true)
        end
      end
    end

    describe "validating array attributes containing forms" do
      context "when the array of forms has valid values" do
        it "returns true" do
          form = UserForm.new(
            :first_name => "Andy",
            :contacts   => [ContactForm.new(:name => "Andy")]
          )

          expect(form).to be_valid
          expect(form.contacts.first).to be_valid
        end
      end

      context "when the array of forms has invalid values" do
        it "returns false" do
          form = UserForm.new(
            :first_name => "Andy",
            :contacts => [ContactForm.new(:name => "")]
          )

          expect(form).not_to be_valid
          expect(form.contacts.first).not_to be_valid
        end
      end

      context "when ignoring narray of forms with invalid values" do
        it "returns true" do
          form = UserForm.new(
            :first_name => "Andy",
            :contacts => [ContactForm.new(:name => "")]
          )

          expect(form).to be_valid(:exclude_arrays => true)
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

  describe "#with_context" do
    it "assigns a context hash and allows access in the form" do
      form = UserForm.new(:first_name => "Andy")
        .with_context(:account_id => 1)

      expect(form.context.account_id).to eq(1)
    end

    it "assigns a context to nested forms" do
      form = SchoolForm.new(
        :head => TeacherForm.new(:name => "")
      ).with_context(:account_id => 1)

      expect(form.head.context.account_id).to eq(1)
    end

    it "assigns a context to array attribute child forms" do
      form = UserForm.new(
        :first_name => "Andy",
        :contacts   => [ContactForm.new(:name => "Andy")]
      ).with_context(:account_id => 1)

      expect(form.contacts.first.context.account_id).to eq(1)
    end
  end
end
