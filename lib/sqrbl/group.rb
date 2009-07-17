module Sqrbl
  class Group
    attr_reader :migration, :description, :block, :todos, :steps

    def initialize(migration, description, options = {}, &block)
      @todos       = []
      @steps       = []
      @migration   = migration
      @description = description
      @block       = lambda(&block)

      evaluate_block! unless options[:skip_block_evaluation]
    end

    def method_missing(method, *args, &block)
      migration.send(method, *args, &block)
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

    protected
    def evaluate_block!
      instance_eval(&block) if block
    end
  end
end
