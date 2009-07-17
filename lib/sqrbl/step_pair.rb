module Sqrbl
  class StepPair
    attr_reader :group, :description, :block
    attr_reader :up_step, :down_step

    def initialize(group, description, options = {}, &block)
      @group       = group
      @description = description
      @block       = lambda(&block)

      evaluate_block! unless options[:skip_block_evaluation]
    end

    def method_missing(method, *args, &block)
      group.send(method, *args, &block)
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

    protected
    def evaluate_block!
      instance_eval(&block) if block
    end
  end
end