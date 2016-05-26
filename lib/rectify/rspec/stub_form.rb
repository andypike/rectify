module Rectify
  class StubForm
    attr_accessor :attributes

    def initialize(attributes)
      @attributes = attributes
    end

    def invalid?
      !valid?
    end

    def method_missing(method_name, *args, &block)
      if attributes.key?(method_name)
        attributes[method_name]
      elsif method_name.to_s.ends_with?("=")
        attribute_name = method_name.to_s.chomp("=").to_sym
        attributes[attribute_name] = args.first
      else
        super
      end
    end

    def respond_to_missing?(method_name, _include_private = false)
      attributes.key?(method_name)
    end
  end
end
