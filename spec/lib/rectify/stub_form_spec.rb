RSpec.describe Rectify::StubForm do
  describe "stub_form helper" do
    it "returns a Rectify::StubForm" do
      form = stub_form(name: "Andy", age: 38)

      expect(form).to be_a(described_class)
    end

    it "matches the passed attributes" do
      form = stub_form(name: "Andy", age: 38)

      expect(form.name).to eq("Andy")
      expect(form.age).to eq(38)
    end
  end

  describe "#valid?" do
    it "returns the true when true is passed in the constructor" do
      form = described_class.new(:valid? => true)

      expect(form).to be_valid
    end

    it "returns the false when false is passed in the constructor" do
      form = described_class.new(:valid? => false)

      expect(form).not_to be_valid
    end
  end

  describe "#invalid?" do
    it "returns the opposite of `valid?`" do
      form = described_class.new(:valid? => true)

      expect(form).not_to be_invalid
    end
  end

  describe "#attributes" do
    it "turns a hash passed to the constructor to attributes" do
      form = described_class.new(name: "Andy", age: 38)

      expect(form.name).to eq("Andy")
      expect(form.age).to eq(38)
    end

    it "returns the attributes hash" do
      form = described_class.new(name: "Andy", age: 38)

      expect(form.attributes).to eq(name: "Andy", age: 38)
    end

    it "allows assignment of attributes passed into the constructor" do
      form = described_class.new(name: "Andy", age: 38)
      form.name = "Fred"

      expect(form.name).to eq("Fred")
    end

    it "allows assignment of new attributes" do
      form = described_class.new(name: "Andy", age: 38)
      form.twitter = "andypike"

      expect(form.twitter).to eq("andypike")
    end

    it "doesn't return :valid?" do
      form = described_class.new(:valid? => true, name: "Andy", age: 38)

      expect(form.attributes).to eq(name: "Andy", age: 38)
    end
  end
end
