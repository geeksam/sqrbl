module Sqrbl
  module HasTodos
    Todo = Struct.new(:message, :call_stack) do
      def location
        call_stack.first
      end
    end

    def todos
      @todos ||= []
    end

    def todo(message)
      todos << Todo.new(message, caller)
    end
  end
end
