require File.join(File.dirname(__FILE__), %w[.. spec_helper])

include Sqrbl

describe BaseConversionWriter do
  it "should know what its subclasses are" do
    BaseConversionWriter.subclasses.should == [
      IndividualConversionWriter,
      UnifiedConversionWriter,
    ]
  end
end
