require File.join(File.dirname(__FILE__), %w[.. spec_helper])

include Sqrbl

describe Sqrbl do

  describe :migration do
    it "should invoke Sqrbl::Migration.build, passing it the block" do
      Migration.should_receive(:build).and_yield
      Sqrbl.migration { 'Hello, world!' }
    end

    it "should return an instance of Sqrbl::Migration" do
      migration = Sqrbl.migration { 'hello, world!' }
      migration.should be_kind_of(Sqrbl::Migration)
    end

    it "should take the return value from Sqrbl::Migration.build and pass it to write_migration"
  end

  describe :write_migration do
    # MOCK
    it "should take a migration object"
    it "should pass that migration object off to any and all writers that exist"
  end

end
