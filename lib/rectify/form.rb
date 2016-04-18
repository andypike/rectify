module Rectify
  class Form
    include Virtus.model
    include ActiveModel::Validations

    attribute :id, Integer

    def self.from_params(params, additional_params = {})
      attributes = hash_from(params)
        .fetch(mimicked_model_name, {})
        .merge(additional_params)

      new(attributes).tap do |f|
        f.id = params[:id]
      end
    end

    def self.from_model(model)
      new.tap do |form|
        attribute_set.each do |a|
          if model.respond_to?(a.name)  # the model has a matching method/attribute
            model_value = model.public_send(a.name) # get the value of the attribute from the model, could be a collection, other model or simple type
            if a.primitive.respond_to?(:from_model) # if the form attribute type is a nested form object (belongs_to)
              form.public_send("#{a.name}=", a.primitive.from_model(model_value)) # use the .from_model method of that form object
            elsif a.type.respond_to?(:member_type) && a.type.member_type.respond_to?(:from_model) # if the form attribute is a collection (Set or Array) and it contains form objects (has_many)
              child_forms = model_value.map { |child_model| a.type.member_type.from_model(child_model) } # map each of the associated models to the form object of the collection
              form.public_send("#{a.name}=", child_forms) # set the form object collection attribute to the mapped collection (array of form objects)
            else
              form.public_send("#{a.name}=", model_value) # set the form object attribute to the value returned by the model method/attribute
            end
          end
        end
      end
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

    def self.hash_from(params)
      params = params.to_unsafe_h if params.respond_to?(:to_unsafe_h)
      params.with_indifferent_access
    end

    def persisted?
      id.present? && id.to_i > 0
    end

    def valid?(context = nil)
      [super, form_attributes_valid?, arrays_attributes_valid?].all?
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

    private

    def form_attributes_valid?
      attributes
        .each_value
        .select { |f| f.respond_to?(:valid?) }
        .map(&:valid?)
        .all?
    end

    def arrays_attributes_valid?
      attributes
        .each_value
        .select { |a| a.is_a?(Array) }
        .flatten
        .select { |f| f.respond_to?(:valid?) }
        .map(&:valid?)
        .all?
    end
  end
end
