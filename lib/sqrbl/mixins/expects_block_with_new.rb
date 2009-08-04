# This file is part of SQrbL, which is free software licensed under v3 of the GNU GPL.
# For more information, please see README.txt and LICENSE.txt in the project's root directory.


module Sqrbl
  # This module primarily exists to help with testing.
  # It encapsulates the common pattern of a method on one object
  # that takes a block, creates a new object, and passes the block
  # to the new object.
  #
  # In normal use, the new object should then immediately instance_eval
  # the block; however, for testing, it is sometimes useful to delay
  # block evaluation until later so we can set up mocking beforehand.
  #
  # (Search the /spec directory for "skip_block_evaluation" for examples.)
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
