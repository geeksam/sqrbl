# This file is part of SQrbL, which is free software licensed under v3 of the GNU GPL.
# For more information, please see README.txt and LICENSE.txt in the project's root directory.


module Sqrbl
  module HasTodos
    Todo = Struct.new(:message, :call_stack) do
      def location
        # Find the first caller that isn't inside this library
        call_stack.detect { |call| !call.include?(Sqrbl::LIBPATH) }
      end
    end

    def todos
      @todos ||= []
    end

    def todo(message)
      returning Todo.new(message, caller) do |new_todo|
        todos << new_todo
      end
    end
  end
end
