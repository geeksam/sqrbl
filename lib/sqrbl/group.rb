module Sqrbl
  class Group
    attr_reader :migration, :description, :block, :todos, :steps

    include Sqrbl::ExpectsBlockWithNew
    include Sqrbl::MethodMissingDelegation
    delegate_method_missing_to :migration

    def initialize(migration, description, options = {}, &block)
      @todos       = []
      @steps       = []
      @migration   = migration
      @description = description
      @block       = lambda(&block)

      eval_block_on_initialize(options)
    end

    def todo(message)
      todos << Todo.new(message, caller)
    end

    def step(message, &block)
      steps << StepPair.new(self, message, &block)
    end

    def valid?
      !steps.empty? && steps.all? { |step| step.kind_of?(StepPair) }
    end
  end
end
