RSpec.describe Rectify::SaveCommand do
  let(:model) { User.new }

  subject { described_class.new(form, model) }

  context "when the form is invalid" do
    let(:form) { double(:valid? => false) }

    it "broadcasts :invalid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end

  context "when the form is invalid" do
    let(:form) do
      double(:valid? => true, :attributes => { :first_name => "Andy" })
    end

    it "update the model's attributes" do
      subject.call

      expect(model).to have_attributes(:first_name => "Andy")
    end

    it "saves the model" do
      expect(model).to receive(:save!)

      subject.call
    end

    it "broadcasts :ok" do
      expect { subject.call }.to broadcast(:ok)
    end
  end
end
