module Sqrbl
  class Step
    attr_reader :step_pair, :block

    include Sqrbl::ExpectsBlockWithNew
    include Sqrbl::MethodMissingDelegation
    delegate_method_missing_to :step_pair
    include HasTodos

    def initialize(step_pair, options = {}, &block)
      @step_pair = step_pair
      @block = lambda(&block)

      eval_block_on_initialize(options)
    end
  end
end
