module Sqrbl
  class Migration
    attr_reader :groups

    def self.build(&block)
      returning(self.new) do |migration|
        migration.instance_eval(&block)
      end
    end

    def initialize
      @groups = []
    end

    def group(name, &block)
      groups << Group.new(self, name, &block)
    end
  end
end
