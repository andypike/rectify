class ReturnMultiEventMultiResultCommand < Rectify::Command
  def call
    broadcast(:ok, 1, 2, 3)
    broadcast(:published, "The command works")
    broadcast(:next)
  end
end
