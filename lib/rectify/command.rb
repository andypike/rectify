module Rectify
  class Command
    include Wisper::Publisher

    def self.call(*args, &block)
      new(*args).tap do |command|
        command.evaluate(&block) if block_given?
      end.call
    end

    def evaluate(&block)
      @caller = eval("self", block.binding)
      instance_eval(&block)
    end

    def expose(instance_variables)
      instance_variables.each do |name, value|
        @caller.instance_variable_set("@#{name}", value)
      end
    end

    def transaction(&block)
      ActiveRecord::Base.transaction(&block) if block_given?
    end

    def method_missing(method_name, *args, &block)
      if @caller.respond_to?(method_name)
        @caller.send(method_name, *args, &block)
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      @caller.respond_to?(method_name, include_private)
    end
  end
end
