require 'fileutils'

module Sqrbl
  class BaseMigrationWriter
    attr_accessor :migration, :target_directory

    def initialize(migration, target_directory)
      @migration        = migration
      @target_directory = target_directory
    end

    protected
    def ensure_target_dir_exists
      return if File.directory?(target_directory)
      FileUtils.makedirs target_directory
    end

    def write_file(filename, contents)
      filename = File.join(target_directory, filename)
      File.open(filename, 'w') { |f| f << contents }
    end
  end
end
