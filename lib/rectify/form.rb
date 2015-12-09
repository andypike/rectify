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

    def self.from_model(model)
      new(model.attributes)
    end

    def self.route_as(model_name)
      @model_name = model_name.to_s.camelize
    end

    def self.model_name
      ActiveModel::Name.new(self, nil, @model_name)
    end

    def persisted?
      id.present? && id.to_i > 0
    end
  end
end
