Todo = Struct.new(:message, :call_stack) do
  def location
    call_stack.first
  end
end
