module Sqrbl
  class Group
    attr_reader :migration, :description, :block, :todos, :steps

    def initialize(migration, description, options = {}, &block)
      @todos       = []
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

    protected
    def evaluate_block!
      instance_eval(&block)
    end
  end
end
