RSpec.describe Rectify::SaveCommand do
  let(:model) { spy }

  subject { described_class.new(form, model) }

  context "when the form is invalid" do
    let(:form) { double(:valid? => false) }

    it "broadcasts :invalid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end

  context "when the form is invalid" do
    let(:form) { double(:valid? => true, :attributes => { :name => "Andy" }) }

    it "update the model's attributes" do
      subject.call

      expect(model).to have_received(:attributes=).with(:name => "Andy")
    end

    it "saves the model" do
      subject.call

      expect(model).to have_received(:save!)
    end

    it "broadcasts :ok" do
      expect { subject.call }.to broadcast(:ok)
    end
  end
end
