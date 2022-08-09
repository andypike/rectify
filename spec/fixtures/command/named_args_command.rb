class NamedArgsCommand < Rectify::Command
  def initialize(first_name, last_name, height:, location:, hobby:)
    @first_name = first_name
    @last_name = last_name
    @height = height
    @location = location
    @hobby = hobby
  end

  def call
    broadcast(:ok, "Hello #{first_name}")
  end

  private

  attr_reader :first_name, :last_name, :height, :location, :hobby
end
