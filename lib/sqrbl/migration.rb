# This file is part of SQrbL, which is free software licensed under v3 of the GNU GPL.
# For more information, please see README.txt and LICENSE.txt in the project's root directory.


module Sqrbl

  # The Migration class doesn't do much on its own; it's basically just a
  # container for a list of Group objects, which are created using #group.
  #
  # Note also that because Group includes the MethodMissingDelegation mixin,
  # instance methods defined in the block given to Migration.build will become
  # available to all groups (and their related objects) that belong to a
  # Migration instance.  For more information, see MethodMissingDelegation.
  class Migration
    attr_reader :groups

    include HasTodos

    # Creates a new Migration object and evaluates the block in its binding.
    # As a result, any methods called within the block will affect the state
    # of that object (and that object only).
    #
    # <i>(Eventually, this will also pass the migration to a helper object that
    # will create the tree of output *.sql files.)</i>
    def self.build(&block)
      returning(self.new) do |migration|
        migration.instance_eval(&block)
      end
    end

    def initialize
      @groups = []
    end

    # Creates a Group object, passing it the name and block arguments.
    def group(name, &block)
      groups << Group.new(self, name, &block)
    end
  end
end
