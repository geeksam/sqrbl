# This file is part of SQrbL, which is free software licensed under v3 of the GNU GPL.
# For more information, please see README.txt and LICENSE.txt in the project's root directory.


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
