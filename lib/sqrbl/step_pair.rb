# This file is part of SQrbL, which is free software licensed under v3 of the GNU GPL.
# For more information, please see README.txt and LICENSE.txt in the project's root directory.


module Sqrbl
  # Like the Group class, StepPair doesn't do much on its own.
  # It's basically a container for two Step objects, which are created using
  # +up+ and +down+.  These two steps will usually, but not always, have a
  # one-to-one correspondence in their actions.  <i>(For example, a temp table
  # may take a number of actions to create and populate, but removing it
  # just takes a "DROP TABLE" statement.)</i>
  #
  # * The +up_step+ describes the actions necessary to move the source data one
  #   step closer to the target format.
  # * The +down_step+ describes the actions necessary to undo the actions taken
  #   by the up_step.
  #
  # StepPair delegates +method_missing+ calls to its +group+ object.
  # For more information, see MethodMissingDelegation.
  class StepPair
    attr_reader :group, :description, :block
    attr_reader :up_step, :down_step

    include Sqrbl::ExpectsBlockWithNew
    include Sqrbl::MethodMissingDelegation
    delegate_method_missing_to :group
    include HasTodos

    def initialize(group, description, options = {}, &block)
      @group       = group
      @description = description
      @block       = lambda(&block)

      eval_block_on_initialize(options)
    end

    # Create a Step object, passing it the block.
    def up(&block)
      @up_step = Step.new(self, &block)
    end

    # Create a Step object, passing it the block.
    def down(&block)
      @down_step = Step.new(self, &block)
    end

    # A StepPair is valid if both the up_step and the down_step have been created as Step objects.
    def valid?
      [up_step, down_step].all? { |step| step.kind_of?(Step) }
    end

    def unix_name
      Sqrbl.calculate_unix_name(description)
    end
  end
end
