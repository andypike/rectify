module Rectify
  module ControllerHelpers
    def self.included(base_class)
      base_class.helper_method(:presenter)
    end

    def present(presenter, options = {})
      presenter_type = options.fetch(:for) { :template }

      presenter.attach_controller(self)
      rectify_presenters[presenter_type] = presenter
    end

    def presenter(presenter_type = :template)
      rectify_presenters[presenter_type]
    end

    def expose(presentation_data)
      presentation_data.each do |attribute, value|
        if presenter.respond_to?("#{attribute}=")
          presenter.public_send("#{attribute}=", value)
        else
          instance_variable_set("@#{attribute}", value)
        end
      end
    end

    private

    def rectify_presenters
      @rectify_presenters ||= {}
    end
  end
end
