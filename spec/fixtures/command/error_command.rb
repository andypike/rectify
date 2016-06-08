class ErrorCommand < Rectify::Command
  def call
    raise "This command failed"
  end
end
