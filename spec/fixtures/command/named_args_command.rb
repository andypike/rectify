class NamedArgsCommand < Rectify::Command
  def initialize(name, height:, location:)
    @name = name
    @height = height
    @location = location
  end

  private

  attr_reader :name, :height, :location
end
