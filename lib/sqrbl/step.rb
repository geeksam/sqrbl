# This file is part of SQrbL, which is free software licensed under v3 of the GNU GPL.
# For more information, please see README.txt and LICENSE.txt in the project's root directory.


module Sqrbl
  # The Step class is where most of the work of SQrbL takes place.
  # All of the public methods on this class have side effects:  they
  # take the parameters given, tweak their format in some way, and
  # use them to append data to the +output+ attribute.
  #
  # For example, the following code will cause the DELETE statement
  # to appear in +output+:
  #
  #   action "Drop imported organizational contacts" {
  #     'DELETE FROM new_widgets WHERE note LIKE "Imported from old_widgets"'
  #   }
  #
  # +action+ is the primary method you'll use to do the actual work,
  # but there are a number of other helper methods that let you insert
  # variously-formatted comments, and +insert_into+ helps DRY up some
  # of the verbosity involved in writing INSERT statements.
  class Step
    attr_reader :step_pair, :output, :block

    include Sqrbl::ExpectsBlockWithNew
    include Sqrbl::MethodMissingDelegation
    delegate_method_missing_to :step_pair
    include HasTodos

    # :stopdoc:
    GiantWarningText = <<-EOF
##     ##    ###    #######   ##    ##  ######  ##    ##    #####    ##
##     ##   ## ##   ##    ##  ###   ##    ##    ###   ##   ##   ##   ##
##     ##  ##   ##  ##    ##  ####  ##    ##    ####  ##  ##         ##
##  #  ##  #######  #######   ## ## ##    ##    ## ## ##  ##   ####  ##
## ### ##  ##   ##  ##  ##    ##  ####    ##    ##  ####  ##     ##  ##
#### ####  ##   ##  ##   ##   ##   ###    ##    ##   ###   ##   ##
###   ###  ##   ##  ##    ##  ##    ##  ######  ##    ##    #####    ##
EOF
    GiantWarningSeparator = '#' * GiantWarningText.split(/\n/).map(&:length).max
    GiantWarningTemplate =  "/*" +
                            "\n" + GiantWarningSeparator + "\n" +
                            "\n" + GiantWarningText      +
                            "\n" + GiantWarningSeparator + "\n[[LineNum]]\n[[Message]]" +
                            "\n" + GiantWarningSeparator +
                            "\n" + "*/"
    # :startdoc:

    def initialize(step_pair, options = {}, &block)
      @output    = ''
      @step_pair = step_pair
      @block     = lambda(&block)

      eval_block_on_initialize(options)
    end

    # Writes a commented-out Todo item to +output+.
    #
    # Also, creates a Todo object that may be used to create console
    # output when building the *.sql output files (see HasTodos for
    # more information).
    def todo(message)
      returning(super) do |todo|
        todo_msg = "--> %s %s:\t%s" % ['todo'.upcase, caller_info(todo), todo.message]
        write todo_msg
      end
    end

    # Takes +message+ and writes it to +output+ surrounded by a large
    # block-commented ASCII-art message that reads "WARNING!".  The
    # intent here is to create a large message that stands out when
    # scrolling through the output or copy/pasting it into your SQL
    # client.  This message will also contain information pointing
    # you to the place where +warning+ was called.
    #
    # For example, calling <tt>warning "Danger, Will Robinson!"</tt>
    # from foo.rb on line 42 will append something like the following
    # to +output+:
    #
    #   /*
    #   #######################################################################
    #
    #   ##     ##    ###    #######   ##    ##  ######  ##    ##    #####    ##
    #   ##     ##   ## ##   ##    ##  ###   ##    ##    ###   ##   ##   ##   ##
    #   ##     ##  ##   ##  ##    ##  ####  ##    ##    ####  ##  ##         ##
    #   ##  #  ##  #######  #######   ## ## ##    ##    ## ## ##  ##   ####  ##
    #   ## ### ##  ##   ##  ##  ##    ##  ####    ##    ##  ####  ##     ##  ##
    #   #### ####  ##   ##  ##   ##   ##   ###    ##    ##   ###   ##   ##
    #   ###   ###  ##   ##  ##    ##  ##    ##  ######  ##    ##    #####    ##
    #
    #   #######################################################################
    #   (foo.rb, line 42)
    #   Danger, Will Robinson!
    #   #######################################################################
    #   */
    #
    # Also, creates a Todo object of subtype <tt>:warning</tt> that
    # may be used to create console output when building the *.sql
    # output files (see HasTodos for more information).
    def warning(message)
      returning(super) do |warn|
        giant_warning = GiantWarningTemplate.gsub('[[LineNum]]', caller_info(warn)) \
                                            .gsub('[[Message]]', warn.message)
        write giant_warning
      end
    end
    alias :danger_will_robinson! :warning

    # Outputs a message preceded by the SQL line-comment prefix <tt>"-- "</tt>.
    def comment(message)
      write '-- ' + message
    end

    # Outputs a message surrounded by /* SQL block-comment delimiters */.
    def block_comment(message)
      write "/*\n%s\n*/" % indent(4, unindent(message))
    end

    # Expects a message and a block whose return value is a string.
    # Outputs a comment containing +message+, followed by the return value of the block.
    def action(message, &block_returning_string)
      comment(message)
      write(unindent(block_returning_string.call))
    end

    # Helper method for DRYing up INSERT statements.  Takes a table name
    # and a hash that maps field names to SQL expressions, and builds an
    # INSERT statement that populates those fields.  For example:
    #
    #   insert_into 'new_widgets', {
    #     :name     => 'widget_name',
    #     :part_num => 'CONCAT("X_", part_number)',
    #     :note     => '"Imported from old_widgets"',
    #   }
    #
    # will produce:
    #
    #   INSERT INTO new_widgets (
    #       part_num,
    #       note,
    #       name
    #   )
    #   SELECT
    #       CONCAT("X_", part_number) AS part_num,
    #       "Imported from old_widgets" AS note,
    #       widget_name AS name
    #
    # <i>(Note that this only creates the INSERT INTO and SELECT clauses
    # of a SQL statement.)</i>
    def insert_into(table_name, map_from_fieldname_to_expr = {})
      # Build the "INSERT INTO (foo, bar, baz)" clause
      insert_fields = map_from_fieldname_to_expr.keys.join(",\n")
      insert_clause = "INSERT INTO %s (\n%s\n)\n" % [table_name, indent(4, insert_fields)]

      # Build the "SELECT FROM" clause
      select_fields = map_from_fieldname_to_expr.map { |field_name, expr| "#{expr} AS #{field_name}" }.join(",\n")
      select_clause = "SELECT\n" + indent(4, select_fields)

      insert_clause + select_clause
    end

    # Write +text+ to +output+, followed by newlines.
    # (This is used by most other methods on Step; it's made public
    # in case you want to use it in a way I didn't anticipate.)
    def write(text)
      output << text + "\n\n"
    end

    protected
    # Format caller information from the Todo for output.
    def caller_info(todo)
      "(#{todo.creating_file}, line #{todo.calling_line})"
    end

    # Indents +text+ by +n+ spaces.
    def indent(n, text)
      text.to_s.gsub(/^(.)/, (' ' * n) + '\1')
    end

    # If the first line of +text+ has leading whitespace, remove
    # that same amount of leading whitespace from all lines in +text+.
    #
    # (This is an anal-retentiveness helper method:  it lets you
    # keep your SQL statements indented below the +action+ calls
    # that append them to +output+, while keeping that extra
    # indentation from appearing in your generated *.sql files.)
    def unindent(text)
      return text unless text =~ /^(\s+)/
      text.gsub(Regexp.new("^" + $1), '')
    end
  end
end
