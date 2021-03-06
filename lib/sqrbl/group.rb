# This file is part of SQrbL, which is free software licensed under v3 of the GNU GPL.
# For more information, please see README.txt and LICENSE.txt in the project's root directory.


module Sqrbl
  # Like the Conversion class, Group doesn't do much on its own.
  # It's basically a container for a list of StepPair objects, which are created using #step.
  #
  # Group delegates +method_missing+ calls to its +conversion+ object.
  # For more information, see MethodMissingDelegation.
  class Group
    attr_reader :conversion, :description, :block, :steps

    include Sqrbl::ExpectsBlockWithNew
    include Sqrbl::MethodMissingDelegation
    delegate_method_missing_to :conversion
    include HasTodos

    def initialize(conversion, description, options = {}, &block)
      @conversion   = conversion
      @description = description
      @block       = lambda(&block)
      @steps       = []

      eval_block_on_initialize(options)
    end

    # Creates a StepPair object, passing it the step_description and block arguments.
    def step(step_description, &block)
      steps << StepPair.new(self, step_description, &block)
    end

    # A Group is valid if it contains at least one StepPair object, and all of those objects are themselves valid.
    def valid?
      !steps.empty? && steps.all? { |step| step.kind_of?(StepPair) && step.valid? }
    end

    def unix_name
      Sqrbl.calculate_unix_name(description)
    end
  end
end
