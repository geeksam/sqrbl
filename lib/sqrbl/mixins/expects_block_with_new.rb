module Sqrbl
  module ExpectsBlockWithNew
    protected

    def eval_block_on_initialize(options = {})
      evaluate_block! unless options[:skip_block_evaluation]
    end

    def evaluate_block!
      instance_eval(&block) if block
    end
  end
end
