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

    def insert_into(table_name, map_from_fieldname_to_expr = {})
      # Build the "INSERT INTO (foo, bar, baz)" clause
      insert_fields = map_from_fieldname_to_expr.keys.join(",\n")
      insert_clause = "INSERT INTO %s (\n%s\n)\n" % [table_name, indent(4, insert_fields)]

      # Build the "SELECT FROM" clause
      select_fields = map_from_fieldname_to_expr.map { |field_name, expr| "#{expr} AS #{field_name}" }.join(",\n")
      select_clause = "SELECT\n" + indent(4, select_fields)

      insert_clause + select_clause
    end

    protected
    def write(text)
      output << text + "\n\n"
    end

    def indent(n, text)
      text.to_s.gsub(/^(.)/, (' ' * n) + '\1')
    end

    def strip_extra_indentation(text)
      return text unless text =~ /^(\s+)/
      text.gsub(Regexp.new("^" + $1), '')
    end
  end
end
