# This file is part of SQrbL, which is free software licensed under v3 of the GNU GPL.
# For more information, please see README.txt and LICENSE.txt in the project's root directory.


module Sqrbl
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

    def up(&block)
      @up_step = Step.new(self, &block)
    end
    def down(&block)
      @down_step = Step.new(self, &block)
    end

    def valid?
      [up_step, down_step].all? { |step| step.kind_of?(Step) }
    end
  end
end