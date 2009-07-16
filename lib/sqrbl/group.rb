module Sqrbl
  class Group
    attr_accessor :migration, :description, :block

    def initialize(migration, description, options = {}, &block)
      @migration, @description = migration, description
      @block = lambda(&block)
      evaluate_block! unless options[:skip_block_evaluation]
    end

    def method_missing(method, *args, &block)
      migration.send(method, *args, &block)
    end

    protected
    def evaluate_block!
      instance_eval(&block)
    end
  end
end
