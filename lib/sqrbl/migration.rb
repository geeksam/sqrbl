module Sqrbl
  class Migration
    def self.build(&block)
      migration = self.new
      # migration.instance_eval(&block)
      migration
    end
  end
end