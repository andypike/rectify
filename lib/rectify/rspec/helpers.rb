module Rectify
  module RSpec
    module Helpers
      include Wisper::RSpec::BroadcastMatcher

      def stub_query(query_class, options = {})
        results = options.fetch(:results, [])
        allow(query_class).to receive(:new) { StubQuery.new(results) }
      end

      def stub_form(attributes)
        Rectify::StubForm.new(attributes)
      end
    end
  end
end
