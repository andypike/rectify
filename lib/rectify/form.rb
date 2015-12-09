module Rectify
  class Form
    include Virtus.model

    attribute :id, Integer

    def self.from_params(key, params)
      params     = params.with_indifferent_access
      attributes = params.fetch(key, {})

      new(attributes).tap do |f|
        f.id = params[:id]
      end
    end
  end
end
