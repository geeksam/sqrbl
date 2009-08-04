require 'fileutils'

module Sqrbl
  class UnifiedMigrationWriter < BaseMigrationWriter
    def write!
      ensure_target_dir_exists
      write_file(up_file, all_up_steps_output)
      write_file(down_file, all_down_steps_output)
    end

    def all_up_steps_output
      migration.up_steps.map(&:output).join
    end
    def all_down_steps_output
      migration.down_steps.reverse.map(&:output).join
    end

    protected
    def up_file  ; 'all_up.sql'  ; end
    def down_file; 'all_down.sql'; end
  end
end
