module Rectify
  class Form
    include Virtus.model
    include ActiveModel::Validations

    attr_reader :context

    attribute :id, Integer

    def self.from_params(params, additional_params = {})
      params_hash = hash_from(params)
      mimicked_params = ensure_hash(params_hash[mimicked_model_name])

      attributes_hash = params_hash
        .merge(mimicked_params)
        .merge(additional_params)

      formatted_attributes = FormatAttributesHash
        .new(attribute_set)
        .format(attributes_hash)

      new(formatted_attributes)
    end

    def self.from_model(model)
      Rectify::BuildFormFromModel.new(self, model).build
    end

    def self.from_json(json)
      from_params(JSON.parse(json))
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

    def self.ensure_hash(object)
      if object.is_a?(Hash)
        object
      else
        {}
      end
    end

    def persisted?
      id.present? && id.to_i > 0
    end

    def valid?(options = {})
      before_validation

      options     = {} if options.blank?
      context     = options[:context]
      validations = [super(context)]

      validations << form_attributes_valid? unless options[:exclude_nested]
      validations << array_attributes_valid? unless options[:exclude_arrays]

      validations.all?
    end

    def invalid?(options = {})
      !valid?(options)
    end

    def to_key
      [id]
    end

    def to_model
      self
    end

    def to_param
      id.to_s
    end

    def attributes
      super.except(:id)
    end

    def attributes_with_values
      attributes.reject { |attribute| public_send(attribute).nil? }
    end

    def map_model(model)
      # Implement this in your form object for custom mapping from model to form
      # object as part of the `.from_model` call after matching attributes are
      # populated (optional).
    end

    def before_validation
      # Implement this in your form object if you would like to perform some
      # some processing before validation happens (optional).
    end

    def with_context(new_context)
      @context = if new_context.is_a?(Hash)
                   OpenStruct.new(new_context)
                 else
                   new_context
                 end

      attributes_that_respond_to(:with_context)
        .each { |f| f.with_context(context) }

      array_attributes_that_respond_to(:with_context)
        .each { |f| f.with_context(context) }

      self
    end

    private

    def form_attributes_valid?
      attributes_that_respond_to(:valid?)
        .map(&:valid?)
        .all?
    end

    def array_attributes_valid?
      array_attributes_that_respond_to(:valid?)
        .map(&:valid?)
        .all?
    end

    def attributes_that_respond_to(message)
      attributes
        .each_value
        .select { |f| f.respond_to?(message) }
    end

    def array_attributes_that_respond_to(message)
      attributes
        .each_value
        .select { |a| a.is_a?(Array) }
        .flatten
        .select { |f| f.respond_to?(message) }
    end
  end
end
