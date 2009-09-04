module Sqrbl
  # Writes two files:  output_directory/all_up.sql and output_directory/all_down.sql.
  # * output_directory/all_up.sql contains all 'up' steps, in creation order.
  # * output_directory/all_down.sql contains all 'down' steps, in reverse creation order.
  class UnifiedConversionWriter < BaseConversionWriter
    # Create all_up.sql and all_down.sql in output_directory.
    def write!
      ensure_dir_exists(output_directory)
      write_file(up_file, all_up_steps_output)
      write_file(down_file, all_down_steps_output)
    end

    # Output from all 'up' steps, in creation order
    def all_up_steps_output
      conversion.up_steps.map(&:output).join
    end

    # Output from all 'down' steps, in reverse creation order
    def all_down_steps_output
      conversion.down_steps.reverse.map(&:output).join
    end

    protected
    # Pathname to all_up.sql
    def up_file
      File.join(output_directory, 'all_up.sql'  )
    end

    # Pathname to all_down.sql
    def down_file
      File.join(output_directory, 'all_down.sql')
    end
  end
end
