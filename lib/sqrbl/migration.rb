# This file is part of SQrbL, which is free software licensed under v3 of the GNU GPL.
# For more information, please see README.txt and LICENSE.txt in the project's root directory.


module Sqrbl
  class Migration
    attr_reader :groups

    include HasTodos

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
