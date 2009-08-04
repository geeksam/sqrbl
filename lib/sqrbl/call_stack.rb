module Sqrbl
  # A small set of tools for working with the call stack.
  module CallStack
    module_function

    # Find the first item on the call stack that isn't in the Sqrbl library path
    def first_non_sqrbl_caller(call_stack = caller)
      call_stack.detect { |call| ! call.include?(Sqrbl::LIBPATH) }
    end

    # For a given entry in the call stack, get the file
    def caller_file(caller_item)
      caller_item.split(':')[0]
    end

    # For a given entry in the call stack, get the line number
    def caller_line(caller_item)
      caller_item.split(':')[1]
    end
  end
end
