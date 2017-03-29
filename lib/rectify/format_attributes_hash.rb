# Based on http://stackoverflow.com/questions/8706930/converting-nested-hash-keys-from-camelcase-to-snake-case-in-ruby

module Rectify
  class FormatAttributesHash
    def format(params)
      convert_hash_keys(params)
    end

    private

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
