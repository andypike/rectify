module Rectify
  class BuildFormFromModel
    def initialize(form_class, model)
      @form_class = form_class
      @model = model
    end

    def build
      form.tap do
        matching_attributes.each do |a|
          model_value = model.public_send(a.name)
          form.public_send("#{a.name}=", a.value_from(model_value))
        end

        form.map_model(model)
      end
    end

    private

    attr_reader :form_class, :model

    def form
      @form ||= form_class.new
    end

    def attribute_set
      form_class.attribute_set
    end

    def matching_attributes
      attribute_set
        .select { |a| model.respond_to?(a.name) }
        .map    { |a| FormAttribute.new(a) }
    end
  end
end
