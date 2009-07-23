# This file is part of SQrbL, which is free software licensed under v3 of the GNU GPL.
# For more information, please see README.txt and LICENSE.txt in the project's root directory.


module Sqrbl
  module HasTodos
    Todo = Struct.new(:message, :call_stack, :type) do
      def location
        # Find the first caller that isn't inside this library
        @location ||= call_stack.detect { |call| ! call.include?(Sqrbl::LIBPATH) }
      end
      def calling_line; location.split(':').last;  end
      def calling_file; location.split(':').first; end
      def todo?;    type == :todo;    end
      def warning?; type == :warning; end
    end

    def todos
      @todos ||= []
    end

    def todo(message)
      add_todo(message, caller, :todo)
    end

    def warning(message)
      add_todo(message, caller, :warning)
    end

    protected
    def add_todo(message, caller, type)
      returning Todo.new(message, caller, type) do |new_todo|
        todos << new_todo
      end
    end
  end
end
