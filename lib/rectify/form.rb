module Rectify
  class Form # rubocop:disable Metrics/ClassLength
    include Virtus.model
    include ActiveModel::Validations
    include NestedFormHelpers

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

      options = {} if options.blank?
      context = options[:context]

      super(context)
      validate_nested_attributes(options) unless options[:exclude_nested]
      validate_nested_array_attributes(options) unless options[:exclude_arrays]

      errors.empty?
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

      nested_values.each_value { |form| form.with_context(context) }
      nested_array_values.each_value do |forms|
        forms.each { |form| form.with_context(context) }
      end

      self
    end

    private

    def validate_nested_attributes(options)
      nested_values.each do |attribute, form|
        next if form.valid?(options)

        merge_error_messages(attribute, form, options)
      end
    end

    def validate_nested_array_attributes(options)
      nested_array_values.each do |attribute, forms|
        forms.each_with_index do |form, index|
          next if form.valid?(options)

          merge_error_messages(attribute, form, options, index)
        end
      end
    end

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def merge_error_messages(attribute, form, options, index = nil)
      indexed_attribute = !index.nil? && options[:index_errors]
      form_errors = form.errors

      form_errors.details.each do |nested_attribute, details|
        error_attribute =
          normalize_error_attribute(indexed_attribute, attribute, index, nested_attribute).to_sym

        form_errors[nested_attribute].each do |message|
          errors[error_attribute].push(message).uniq!
        end

        details.each do |error|
          errors.details[error_attribute].push(error).uniq!
        end
      end
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

    def normalize_error_attribute(indexed_attribute, attribute, index, nested_attribute)
      if indexed_attribute
        "#{attribute}[#{index}].#{nested_attribute}"
      else
        "#{attribute}.#{nested_attribute}"
      end
    end
  end
end
