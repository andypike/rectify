class SuccessCommand < Rectify::Command
  def call
    broadcast(:success)
  end
end
