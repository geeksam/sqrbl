# This file is part of SQrbL, which is free software licensed under v3 of the GNU GPL.
# For more information, please see README.txt and LICENSE.txt in the project's root directory.


module Sqrbl

  # The Conversion class doesn't do much on its own; it's basically just a
  # container for a list of Group objects, which are created using #group.
  #
  # Note also that because Group includes the MethodMissingDelegation mixin,
  # instance methods defined in the block given to Conversion.build will become
  # available to all groups (and their related objects) that belong to a
  # Conversion instance.  For more information, see MethodMissingDelegation.
  class Conversion
    attr_reader :groups, :creating_file, :output_directory

    include HasTodos

    # Creates a new Conversion object and evaluates the block in its binding.
    # As a result, any methods called within the block will affect the state
    # of that object (and that object only).
    #
    # <i>(Eventually, this will also pass the conversion to a helper object that
    # will create the tree of output *.sql files.)</i>
    def self.build(&block)
      returning(self.new) do |conversion|
        conversion.instance_eval(&block)
      end
    end

    def initialize # :nodoc:
      @groups = []
      creating_caller = CallStack.first_non_sqrbl_caller
      @creating_file  = File.expand_path(CallStack.caller_file(creating_caller))
    end

    # Convenience method:  set the +output_directory+ attribute
    def set_output_directory(dirname)
      self.output_directory = File.expand_path(dirname)
    end

    # Creates a Group object, passing it the name and block arguments.
    def group(name, &block)
      groups << Group.new(self, name, &block)
    end

    # Convenience method:  iterate all StepPair objects in the conversion
    def step_pairs
      groups.map(&:steps).flatten
    end

    # Convenience method:  iterate all 'up' steps in the conversion
    def up_steps
      step_pairs.map(&:up_step)
    end

    # Convenience method:  iterate all 'down' steps in the conversion
    def down_steps
      step_pairs.map(&:down_step)
    end
  end
end
