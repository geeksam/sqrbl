require 'fileutils'

module Sqrbl
  # Base class for other conversion writers.
  class BaseConversionWriter
    attr_accessor :conversion, :output_directory

    class << self
      # List all classes that inherit from this one
      def subclasses
        @@subclasses ||= []
      end

      def inherited(subclass) #:nodoc:
        subclasses << subclass
      end

      # Convenience method:  create a new instance and invoke <tt>write!</tt> on it.
      def write_conversion!(conversion)
        new(conversion).write!
      end
    end

    def initialize(conversion) #:nodoc:
      @conversion = conversion
      set_default_output_dir!
    end

    protected
    # Set the output_directory attribute based on the output_directory or creating_file
    # attributes of the given conversion, in that order
    def set_default_output_dir!
      raise "No conversion given!" unless conversion
      self.output_directory ||= conversion.output_directory
      self.output_directory ||= conversion.creating_file && File.join(File.expand_path(File.dirname(conversion.creating_file)), 'sql')
      raise "Unable to determine output directory!" unless self.output_directory
    end

    # Make sure that the given directory exists
    def ensure_dir_exists(dirname)
      raise ArgumentError.new("dirname cannot be nil!") if dirname.nil?
      dirname = File.expand_path(dirname)
      return if File.directory?(dirname)
      FileUtils.makedirs(dirname)
    end

    # Open +filename+ and write +contents+ to it
    def write_file(filename, contents)
      File.open(filename, 'w') { |f| f << contents }
    end
  end
end
