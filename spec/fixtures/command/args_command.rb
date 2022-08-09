class ArgsCommand < Rectify::Command
  def initialize(one, two, three)
    @one = one
    @two = two
    @three = three
  end

  private

  attr_reader :one, :two, :three
end
