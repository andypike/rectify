RSpec.describe Rectify::Command do
  describe ".call" do
    let(:instance) { spy }

    context "with no arguments" do
      it "instantiates and invokes #call" do
        expect(NoArgsCommand).to receive(:new).with(no_args) { instance }
        expect(instance).to receive(:call)

        NoArgsCommand.call
      end
    end

    context "with arguments" do
      it "instantiates with the same arguments and invokes #call" do
        expect(ArgsCommand).to receive(:new).with(:a, :b, :c) { instance }
        expect(instance).to receive(:call)

        ArgsCommand.call(:a, :b, :c)
      end
    end

    describe "#on" do
      def success
        @success = true
      end

      def failure
        @failure = true
      end

      it "calls methods on the caller" do
        @success = false
        @failure = false

        SuccessCommand.call do
          on(:success) { success }
          on(:failure) { failure }
        end

        expect(@success).to be(true)
        expect(@failure).to be(false)
      end

      it "sets instance variables on the caller via expose" do
        @success = false

        SuccessCommand.call do
          on(:success) { expose(:success => true) }
        end

        expect(@success).to be(true)
      end
    end
  end
end
