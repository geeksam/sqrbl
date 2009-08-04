require File.join(File.dirname(__FILE__), %w[.. spec_helper])

include Sqrbl

describe Sqrbl do
  it ".build_migration should return an instance of Sqrbl::Migration" do
    migration = Sqrbl.build_migration { 'hello, world!' }
    migration.should be_kind_of(Sqrbl::Migration)
  end

  it ".migration should take the return value from Sqrbl::Migration.build and pass it to write_migration" do
    mig = mock('Migration')
    Migration.should_receive(:build).and_yield.and_return(mig)
    Sqrbl.should_receive(:write_migration!).with(mig)
    Sqrbl.migration { 'Hello, world!' }
  end

  describe :write_migration! do
    it "should take a migration object and pass it off to any and all writers that exist" do
      mig = mock('Migration')
      BaseMigrationWriter.subclasses.each do |writer_class|
        writer_class.should_receive(:write_migration!).with(mig)
      end
      Sqrbl.write_migration!(mig)
    end
  end

end
