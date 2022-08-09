module Rectify
  class EventRecorder
    attr_reader :events

    def initialize
      @events = {}
    end

    # rubocop:disable Style/MethodMissing
    def method_missing(method_name, *args, &_block)
      args = args.first if args.size == 1
      @events[method_name] = args
    end
    # rubocop:enable Style/MethodMissing

    def respond_to_missing?(_method_name, _include_private = false)
      true
    end
  end

  class Command
    include Wisper::Publisher

    def self.call(*args, **kwargs, &block)
      event_recorder = EventRecorder.new

      command = new(*args, **kwargs)
      command.subscribe(event_recorder)
      command.evaluate(&block) if block_given?
      command.call

      event_recorder.events
    end

    def evaluate(&block)
      @caller = eval("self", block.binding, __FILE__, __LINE__)
      instance_eval(&block)
    end

    def transaction(&block)
      ActiveRecord::Base.transaction(&block) if block_given?
    end

    def method_missing(method_name, *args, &block)
      if @caller.respond_to?(method_name, true)
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
