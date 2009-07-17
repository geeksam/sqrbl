module Sqrbl
  class StepPair
    attr_reader :group, :description, :block
    attr_reader :up_step, :down_step

    include Sqrbl::ExpectsBlockWithNew
    include Sqrbl::MethodMissingDelegation
    delegate_method_missing_to :group

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