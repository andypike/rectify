module Rectify
  class Form
    include Virtus.model

    attribute :id, Integer

    def self.from_params(key, params)
      params = params.with_indifferent_access

      new(params.fetch(key)).tap do |form|
        form.id = params[:id]
      end
    end
  end
end
