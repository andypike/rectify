class ErrorCommand < Rectify::Command
  def call
    fail "This command failed"
  end
end
