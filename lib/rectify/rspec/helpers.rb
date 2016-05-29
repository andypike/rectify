module Rectify
  module RSpec
    module Helpers
      include Wisper::RSpec::BroadcastMatcher

      def stub_query(query_class, options = {})
        results = options.fetch(:results, [])
        allow(query_class).to receive(:new) { StubQuery.new(results) }
      end
    end
  end
end
