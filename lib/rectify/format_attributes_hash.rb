# Based on http://stackoverflow.com/questions/8706930/converting-nested-hash-keys-from-camelcase-to-snake-case-in-ruby

module Rectify
  class FormatAttributesHash
    def initialize(attribute_set)
      @attribute_set = attribute_set
    end

    def format(params)
      convert_indexed_hashes_to_arrays(params)
      convert_hash_keys(params)
    end

    private

    attr_reader :attribute_set

    def convert_indexed_hashes_to_arrays(attributes_hash)
      array_attribute_names.each do |name|
        attribute = attributes_hash[name]
        next unless attribute.is_a?(Hash)

        attributes_hash[name] = attribute.values
      end
    end

    def array_attribute_names
      attribute_set.select { |a| a.primitive == Array }.map { |a| a.name.to_s }
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
