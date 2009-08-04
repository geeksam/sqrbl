require File.join(File.dirname(__FILE__), %w[.. spec_helper])

include Sqrbl

describe BaseMigrationWriter do
  it "should know what its subclasses are" do
    BaseMigrationWriter.subclasses.should == [
      IndividualMigrationWriter,
      UnifiedMigrationWriter,
    ]
  end
end
