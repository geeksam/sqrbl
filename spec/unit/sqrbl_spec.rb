require File.join(File.dirname(__FILE__), %w[.. spec_helper])

include Sqrbl

describe Sqrbl do
  it ".build_conversion should return an instance of Sqrbl::Conversion" do
    conversion = Sqrbl.build_conversion { 'hello, world!' }
    conversion.should be_kind_of(Sqrbl::Conversion)
  end

  it ".conversion should take the return value from Sqrbl::Conversion.build and pass it to write_conversion" do
    cvn = mock('Conversion')
    Conversion.should_receive(:build).and_yield.and_return(cvn)
    Sqrbl.should_receive(:write_conversion!).with(cvn)
    Sqrbl.conversion { 'Hello, world!' }
  end

  describe :write_conversion! do
    it "should take a conversion object and pass it off to any and all writers that exist" do
      cvn = mock('Conversion')
      BaseConversionWriter.subclasses.each do |writer_class|
        writer_class.should_receive(:write_conversion!).with(cvn)
      end
      Sqrbl.write_conversion!(cvn)
    end
  end

end
