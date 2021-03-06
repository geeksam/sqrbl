require File.join(File.dirname(__FILE__), %w[.. spec_helper])

include Sqrbl

describe UnifiedConversionWriter do
  describe "for a conversion with #output_directory set" do
    it "should set #output_directory from the conversion's #output_directory" do
      cvn = mock('Conversion', :output_directory => '/path/to/sql', :creating_file => nil)
      writer = UnifiedConversionWriter.new(cvn)
      writer.output_directory.should == cvn.output_directory
    end
  end

  describe "for a conversion with output_directory blank" do
    it "should set #output_directory using the dirname of the conversion's #creating_file, plus /sql" do
      cvn = mock('Conversion', :output_directory => nil, :creating_file => '/path/to/some/sqrbl_file.rb')
      writer = UnifiedConversionWriter.new(cvn)
      writer.output_directory.should == '/path/to/some/sql'
    end
  end

  describe "for a conversion with two groups and three steps" do
    before(:each) do
      @cvn = Sqrbl.build_conversion do
        group 'Group one' do
          step 'Step one' do
            up   { write 'Step one up'   }
            down { write 'Step one down' }
          end
          step 'Step two' do
            up   { write 'Step two up'  }
            down { write 'Step two down'}
          end
        end
        group 'Group two' do
          step 'Step three' do
            up   { write 'Step three up'   }
            down { write 'Step three down' }
          end
        end
      end

      @base_dir = File.expand_path(File.join(File.dirname(__FILE__), 'sql'))
      @writer = UnifiedConversionWriter.new(@cvn)
    end

    it "should not create the target directory if it already exists" do
      File.should_receive(:directory?).with(@base_dir).and_return(true)
      FileUtils.should_not_receive(:makedirs).with(@base_dir)
      stub_out_file_creation
      @writer.write!
    end

    it "should create the target directory if it does not exist" do
      File.should_receive(:directory?).with(@base_dir).and_return(false)
      FileUtils.should_receive(:makedirs).with(@base_dir)
      stub_out_file_creation
      @writer.write!
    end

    it "should create a file 'sql/all_up.sql' in the target directory" do
      File.should_receive(:open).with(File.join(@base_dir, 'all_up.sql'), 'w')
      stub_out_file_creation
      @writer.write!
    end

    it "should combine the contents of all up steps in order" do
      @writer.all_up_steps_output.should == @cvn.up_steps.map(&:output).join
    end

    it "should write the contents of all up steps to the all_up.sql file" do
      mock_file = mock('File')
      File.should_receive(:open).with(File.join(@base_dir, 'all_up.sql'), 'w').and_yield(mock_file)
      mock_file.should_receive(:<<).with(@writer.all_up_steps_output)
      stub_out_file_creation
      @writer.write!
    end

    it "should create a file 'sql/all_down.sql' in the target directory" do
      File.should_receive(:open).with(File.join(@base_dir, 'all_down.sql'), 'w')
      stub_out_file_creation
      @writer.write!
    end

    it "should combine the contents of all down steps in REVERSE order" do
      @writer.all_down_steps_output.should == @cvn.down_steps.reverse.map(&:output).join
    end

    it "should write the contents of all down steps to the all_down.sql file" do
      mock_file = mock('File')
      File.should_receive(:open).with(File.join(@base_dir, 'all_down.sql'), 'w').and_yield(mock_file)
      mock_file.should_receive(:<<).with(@writer.all_down_steps_output)
      stub_out_file_creation
      @writer.write!
    end
  end
end
