# frozen_string_literal: true

module Rectify
  module NestedFormHelpers
    private

    def nested_values
      nested_attributes.each_with_object({}) do |attribute, attributes|
        attribute_name = attribute.name
        next unless (value = __send__(attribute_name))

        attributes[attribute_name] = value
      end
    end

    def nested_array_values
      nested_array_attributes.each_with_object({}) do |attribute, attributes|
        attribute_name = attribute.name
        next if (value = __send__(attribute_name)).empty?

        attributes[attribute_name] = value
      end
    end

    def nested_attributes
      @nested_attributes ||= attribute_set.select do |attribute|
        attribute.primitive < ::Rectify::Form
      end
    end

    def array_attributes
      @array_attributes ||= attribute_set.select do |attribute|
        attribute.primitive.eql?(Array)
      end
    end

    def nested_array_attributes
      @nested_array_attributes ||= array_attributes.select do |attribute|
        attribute.member_type.primitive < ::Rectify::Form
      end
    end
  end
end
