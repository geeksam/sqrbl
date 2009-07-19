# This file is part of SQrbL, which is free software licensed under v3 of the GNU GPL.
# For more information, please see README.txt and LICENSE.txt in the project's root directory.


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
