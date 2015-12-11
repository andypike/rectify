module Rectify
  class Form
    include Virtus.model
    include ActiveModel::Validations

    attribute :id, Integer

    def self.from_params(params, additional_params = {})
      params     = params.with_indifferent_access
      attributes = params.fetch(mimicked_model_name, {}).merge(additional_params)

      new(attributes).tap do |f|
        f.id = params[:id]
      end
    end

    def self.from_model(model)
      new(model.attributes)
    end

    def self.mimic(model_name)
      @model_name = model_name.to_s.underscore.to_sym
    end

    def self.mimicked_model_name
      @model_name || infer_model_name
    end

    def self.infer_model_name
      class_name = name.split("::").last
      return :form if class_name == "Form"

      class_name.chomp("Form").underscore.to_sym
    end

    def self.model_name
      ActiveModel::Name.new(self, nil, mimicked_model_name.to_s.camelize)
    end

    def persisted?
      id.present? && id.to_i > 0
    end

    def to_key
      [id]
    end

    def to_model
      self
    end

    def attributes
      super.except(:id)
    end
  end
end
