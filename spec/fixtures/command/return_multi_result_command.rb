class ReturnMultiResultCommand < Rectify::Command
  def call
    broadcast(:ok, 1, 2, 3)
  end
end
