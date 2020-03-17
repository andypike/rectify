# Based on http://stackoverflow.com/questions/8706930/converting-nested-hash-keys-from-camelcase-to-snake-case-in-ruby

module Rectify
  class FormatAttributesHash
    def initialize(attribute_set)
      @attribute_set = attribute_set
    end

    def format(params)
      convert_indexed_hashes_to_arrays_for_nested_attributes(params)
      convert_indexed_hashes_to_arrays_for_array_attributes(params)
      convert_hash_keys(params)
    end

    private

    attr_reader :attribute_set

    def convert_indexed_hashes_to_arrays_for_array_attributes(attributes_hash)
      array_attributes.each do |array_attribute|
        name = array_attribute.name
        attribute = attributes_hash[name]
        next unless attribute.is_a?(Hash)

        attributes_hash[name] = transform_values_for_type(
          attribute.values,
          array_attribute.member_type.primitive
        )
      end
    end

    def convert_indexed_hashes_to_arrays_for_nested_attributes(attributes_hash)
      nested_attributes.each do |nested_form_attribute|
        name = nested_form_attribute.name
        attribute = attributes_hash[name]
        next unless attribute.is_a?(Hash)

        attributes_hash[name] =
          self.class.new(nested_form_attribute.primitive.attribute_set).format(attribute)
      end
    end

    def transform_values_for_type(values, element_type)
      return values unless element_type < Rectify::Form

      values.map do |value|
        self.class.new(element_type.attribute_set).format(value)
      end
    end

    def nested_attributes
      attribute_set.select { |attribute| attribute.primitive < ::Rectify::Form }
    end

    def array_attributes
      attribute_set.select { |attribute| attribute.primitive == Array }
    end

    def convert_hash_keys(value)
      case value
      when Array
        value.map { |v| convert_hash_keys(v) }
      when Hash
        Hash[value.map { |k, v| [underscore_key(k), convert_hash_keys(v)] }]
      else
        value
      end
    end

    def underscore_key(k)
      k.to_s.underscore.to_sym
    end
  end
end
