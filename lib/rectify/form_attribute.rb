module Rectify
  class FormAttribute < SimpleDelegator
    def value_from(model_value)
      return declared_class.from_model(model_value) if form_object?

      if collection_of_form_objects?
        return model_value.map { |child| element_class.from_model(child) }
      end

      model_value
    end

    private

    def form_object?
      declared_class.respond_to?(:from_model)
    end

    def collection_of_form_objects?
      collection? && element_class.respond_to?(:from_model)
    end

    def collection?
      type.respond_to?(:member_type)
    end

    def element_class
      type.member_type
    end

    def declared_class
      primitive
    end
  end
end
