# This file is part of SQrbL, which is free software licensed under v3 of the GNU GPL.
# For more information, please see README.txt and LICENSE.txt in the project's root directory.


module Sqrbl

  module HasTodos
    class Todo
      attr_accessor :message, :call_stack, :type
      def initialize(message, call_stack, type)
        @message    = message
        @call_stack = call_stack
        @type       = type
      end

      # Returns the first item from the call stack that isn't inside the Sqrbl library.
      # This lets us output a pointer back to the place where this instance was created.
      def location
        @location ||= call_stack.detect { |call| ! call.include?(Sqrbl::LIBPATH) }
      end

      # Return just the line number from +location+.
      def calling_line
        location.split(':').last
      end

      # Return just the filename from +location+.
      def calling_file
        location.split(':').first
      end

      # Is this Todo of type <tt>:todo</tt>?
      def todo?
        type == :todo
      end

      # Is this Todo of type <tt>:warning</tt>?
      def warning?
        type == :warning
      end
    end

    # Return the list of Todo items.
    def todos
      @todos ||= []
    end

    # Create a new Todo item (of type <tt>:todo</tt>) and add it to +todos+.
    def todo(message)
      add_todo(message, caller, :todo)
    end

    # Create a new Todo item (of type <tt>:warning</tt>) and add it to +todos+.
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
