# This file is part of SQrbL, which is free software licensed under v3 of the GNU GPL.
# For more information, please see README.txt and LICENSE.txt in the project's root directory.


module Sqrbl
  class Group
    attr_reader :migration, :description, :block, :steps

    include Sqrbl::ExpectsBlockWithNew
    include Sqrbl::MethodMissingDelegation
    delegate_method_missing_to :migration
    include HasTodos

    def initialize(migration, description, options = {}, &block)
      @todos       = []
      @steps       = []
      @migration   = migration
      @description = description
      @block       = lambda(&block)

      eval_block_on_initialize(options)
    end

    def step(message, &block)
      steps << StepPair.new(self, message, &block)
    end

    def valid?
      !steps.empty? && steps.all? { |step| step.kind_of?(StepPair) }
    end
  end
end
