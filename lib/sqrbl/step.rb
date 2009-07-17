module Sqrbl
  class Step
    attr_reader :step_pair, :block

    def initialize(step_pair, options = {}, &block)
      @step_pair = step_pair
      @block = lambda(&block)

      evaluate_block! unless options[:skip_block_evaluation]
    end

    protected
    def evaluate_block!
      instance_eval(&block) if block
    end
  end
end