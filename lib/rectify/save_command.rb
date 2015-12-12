module Rectify
  class SaveCommand < Command
    def initialize(form, model)
      @form  = form
      @model = model
    end

    def call
      return broadcast(:invalid) unless form.valid?

      model.attributes = form.attributes
      model.save!

      broadcast(:ok)
    end

    private

    attr_reader :form, :model
  end
end
