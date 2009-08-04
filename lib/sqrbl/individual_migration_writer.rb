module Sqrbl
  # Writes one [numbered] file per migration step, in two main directories:  sql/up/ and sql/down/.
  # Migration steps are contained in a [numbered] subfolder that corresponds to the group.
  class IndividualMigrationWriter < BaseMigrationWriter
    # Prepare the up and down directories and populate them with individual files.
    #
    # WARNING:  <b>RECURSIVELY DELETES ALL FILES</b> in output_directory/up and output_directory/down unless passed :safe_mode => true in the options hash!
    def write!(options = {})
      ensure_dir_exists(output_directory)
      clear_dirs!(options)
      write_individual_files!
    end

    protected
    # Recursively delete all files in output_directory/up and output_directory/down unless passed :safe_mode => true in the options hash.
    def clear_dirs!(options)
      return if options[:safe_mode]
      base_dir = File.expand_path(output_directory)
      FileUtils.rm_rf(File.join(base_dir, 'up'))
      FileUtils.rm_rf(File.join(base_dir, 'down'))
    end

    # Write out the contents of the individual files, each in its group's subfolder
    def write_individual_files!
      migration.groups.each_with_index do |group, idx|
        group_dir   = "%0#{group_num_width}d_%s" % [idx + 1, group.unix_name]
        up_subdir   = File.join(output_directory, 'up',   group_dir)
        down_subdir = File.join(output_directory, 'down', group_dir)
        ensure_dir_exists(up_subdir)
        ensure_dir_exists(down_subdir)

        group.steps.each_with_index do |step, idx|
          step_filename = "%0#{step_num_width(step)}d_%s.sql" % [idx + 1, step.unix_name]
          write_file(File.join(up_subdir,   step_filename), step.up_step.output  )
          write_file(File.join(down_subdir, step_filename), step.down_step.output)
        end
      end
    end

    def group_num_width # :nodoc:
      migration.groups.length.to_s.length
    end

    def step_num_width(step) # :nodoc:
      step.group.steps.length.to_s.length
    end
  end
end
