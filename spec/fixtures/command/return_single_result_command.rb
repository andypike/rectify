class ReturnSingleResultCommand < Rectify::Command
  def call
    broadcast(:ok, "This is a result")
  end
end
