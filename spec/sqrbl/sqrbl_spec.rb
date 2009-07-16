require File.join(File.dirname(__FILE__), %w[.. spec_helper])


describe Sqrbl do

  describe :migration do
    it "should take a block and pass it to Sqrbl::Migration.build" do
      Sqrbl::Migration.should_receive(:build).with { 'hello, world!' }
      Sqrbl.migration { 'hello, world!' }
    end

    it "should return an instance of Sqrbl::Migration" do
      migration = Sqrbl.migration { 'hello, world!' }
      migration.should be_kind_of(Sqrbl::Migration)
    end

    it "should take the return value from build_migration and pass it to write_migration"
  end

  describe :build_migration do
    it "should take a block"
    it "should build a migration object"
    it "migration object should have a set of groups"
  end

  describe :write_migration do
    # MOCK
    it "should take a migration object"
    it "should pass that migration object off to any and all writers that exist"
    # Hello, mocking!
  end

end
