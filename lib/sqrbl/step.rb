# This file is part of SQrbL, which is free software licensed under v3 of the GNU GPL.
# For more information, please see README.txt and LICENSE.txt in the project's root directory.


module Sqrbl
  class Step
    attr_reader :step_pair, :output, :block

    include Sqrbl::ExpectsBlockWithNew
    include Sqrbl::MethodMissingDelegation
    delegate_method_missing_to :step_pair
    include HasTodos

    def initialize(step_pair, options = {}, &block)
      @output    = ''
      @step_pair = step_pair
      @block     = lambda(&block)

      eval_block_on_initialize(options)
    end

    def todo(message)
      returning(super) do |todo|
        calling_file, calling_line = todo.location.split(':')
        todo_msg = "--> TODO (#{calling_file}, line #{calling_line}):\t#{message}"
        write todo_msg
      end
    end

    def comment(message)
      write '-- ' + message
    end

    def block_comment(message)
      write "/*\n%s\n*/" % indent(4, strip_extra_indentation(message))
    end

    def action(message, &block)
      comment(message)
      write(strip_extra_indentation(yield))
    end

    protected
    def write(text)
      output << text + "\n"
    end

    def indent(n, text)
      text.gsub(/^(.)/, (' ' * n) + '\1')
    end

    def strip_extra_indentation(text)
      return text unless text =~ /^(\s+)/
      text.gsub(Regexp.new("^" + $1), '')
    end
  end
end
