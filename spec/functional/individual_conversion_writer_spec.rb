require File.join(File.dirname(__FILE__), %w[.. spec_helper])

include Sqrbl

describe IndividualConversionWriter do
  before(:each) do
    @cvn = Sqrbl.build_conversion do
      group 'Group one' do
        step 'Step one' do
          up   { write 'Step one up'   }
          down { write 'Step one down' }
        end
      end
    end

    @base_dir = File.expand_path(File.join(File.dirname(__FILE__), 'sql'))
    @writer = IndividualConversionWriter.new(@cvn)
  end

  it "should have a output_directory attribute" do
    @writer.output_directory.should == @base_dir
  end

  describe :write! do
    it "should clear the sql/up and sql/down directories (yes, this is dangerous)" do
      FileUtils.should_receive(:rm_rf).with(File.join(File.expand_path(@base_dir), 'up')  )
      FileUtils.should_receive(:rm_rf).with(File.join(File.expand_path(@base_dir), 'down'))
      stub_out_file_creation
      @writer.write!
    end

    it "should NOT clear the sql/up and sql/down directories if passed :safe_mode => true" do
      FileUtils.should_not_receive(:rm_rf)
      stub_out_file_creation
      @writer.write!(:safe_mode => true)
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
      @writer = IndividualConversionWriter.new(@cvn)
    end

    it "should create a separate subdirectory in [output_directory]/up for each group" do
      @cvn.groups.each_with_index do |group, idx|
        group_dir   = "#{idx + 1}_#{group.unix_name}"
        up_subdir   = File.join(@writer.output_directory, 'up',   group_dir)
        down_subdir = File.join(@writer.output_directory, 'down', group_dir)
        File     .should_receive(:directory?).with(up_subdir  ).and_return(false)
        File     .should_receive(:directory?).with(down_subdir).and_return(false)
        FileUtils.should_receive(:makedirs).with(up_subdir  )
        FileUtils.should_receive(:makedirs).with(down_subdir)
      end
      stub_out_file_creation
      @writer.write!
    end

    it "should create a separate file for each step, in the subdirectory for that step's group" do
      @cvn.groups.each_with_index do |group, idx|
        group_dir     = "#{idx + 1}_#{group.unix_name}"
        up_subdir   = File.join(@writer.output_directory, 'up',   group_dir)
        down_subdir = File.join(@writer.output_directory, 'down', group_dir)
        group.steps.each_with_index do |step, idx|
          up_step_filename   = File.join(up_subdir,   "#{idx + 1}_#{step.up_step.unix_name  }.sql")
          down_step_filename = File.join(down_subdir, "#{idx + 1}_#{step.down_step.unix_name}.sql")

          @writer.should_receive(:write_file).with(up_step_filename,   step.up_step.output  )
          @writer.should_receive(:write_file).with(down_step_filename, step.down_step.output)
        end
      end
      stub_out_file_creation
      @writer.write!
    end
  end

  describe "for a conversion with 10 groups" do
    before(:each) do
      @cvn = Sqrbl.build_conversion do
        group 'Group one' do
          step 'Step one' do
            up   { write 'Step one up'   }
            down { write 'Step one down' }
          end
        end
        group 'Group two' do
          step 'Step two' do
            up   { write 'Step two up'  }
            down { write 'Step two down'}
          end
        end
        group 'Group three' do
          step 'Step three' do
            up   { write 'Step three up'   }
            down { write 'Step three down' }
          end
        end
        group 'Group four' do
          step 'Step four' do
            up   { write 'Step four up'   }
            down { write 'Step four down' }
          end
        end
        group 'Group five' do
          step 'Step five' do
            up   { write 'Step five up'   }
            down { write 'Step five down' }
          end
        end
        group 'Group six' do
          step 'Step six' do
            up   { write 'Step six up'   }
            down { write 'Step six down' }
          end
        end
        group 'Group seven' do
          step 'Step seven' do
            up   { write 'Step seven up'   }
            down { write 'Step seven down' }
          end
        end
        group 'Group eight' do
          step 'Step eight' do
            up   { write 'Step eight up'   }
            down { write 'Step eight down' }
          end
        end
        group 'Group nine' do
          step 'Step nine' do
            up   { write 'Step nine up'   }
            down { write 'Step nine down' }
          end
        end
        group 'Group ten' do
          step 'Step ten' do
            up   { write 'Step ten up'   }
            down { write 'Step ten down' }
          end
        end
      end

      @writer = IndividualConversionWriter.new(@cvn)
    end

    it "should left-fill the group numbers with zeros" do
      group_ten_up_dir = File.join(@writer.output_directory, 'up', '10_group_ten')
      File.should_receive(:directory?).with(group_ten_up_dir).and_return(false)
      FileUtils.should_receive(:makedirs).with(group_ten_up_dir).once
      stub_out_file_creation
      @writer.write!
    end
  end
end
