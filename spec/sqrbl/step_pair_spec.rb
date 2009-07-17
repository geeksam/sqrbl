require File.join(File.dirname(__FILE__), %w[.. spec_helper])

include Sqrbl

describe StepPair do
  before(:each) do
    @group = mock('Group')
  end

  it "should evaluate the block in its own context" do
    step_pair = StepPair.new(@group, "foo", :skip_block_evaluation => true) do
      hello_world()
    end
    step_pair.should_receive(:hello_world)
    step_pair.send(:evaluate_block!)
  end

  it "should delegate method_missing calls back to the group object" do
    @group.should_receive(:goodbye_world)
    step_pair = StepPair.new(@group, "foo") do
      goodbye_world()
    end
  end

  it "methods defined in the step_pair block should become available as methods on the StepPair instance" do
    step_pair = StepPair.new(@group, "foo") do
      def hello_world
        "Hello, world!"
      end
    end
    step_pair.should respond_to(:hello_world)
    step_pair.hello_world.should == "Hello, world!"
  end

  describe "when #up is called" do
    it "should create a Step object and pass it the StepPair and the block arg" do
      step_pair = StepPair.new(@group, "foo") do
        Step.should_receive(:new).with(self).and_yield # Look weird?  See ./README.txt
        up {}
      end
    end

    it "should put the Step object in its up_step attribute" do
      step_pair = StepPair.new(@group, "foo") do
        up {}
      end
      step_pair.up_step.should be_kind_of(Step)
    end
  end

  describe "when #down is called" do
    it "should create a Step object and pass it the StepPair and the block arg" do
      step_pair = StepPair.new(@group, "foo") do
        Step.should_receive(:new).with(self).and_yield # Look weird?  See ./README.txt
        down {}
      end
    end

    it "should put the Step object in its down_step attribute" do
      step_pair = StepPair.new(@group, "foo") do
        down {}
      end
      step_pair.down_step.should be_kind_of(Step)
    end
  end

  describe :valid? do
    it "should return false if up_step is nil" do
      step_pair = StepPair.new(@group, "foo") do
      end
      step_pair.should_not be_valid
    end
    it "should return false if up_step is nil and down_step is not nil" do
      step_pair = StepPair.new(@group, "foo") do
        down {}
      end
      step_pair.should_not be_valid
    end
    it "should return false if up_step is not nil and down_step is nil" do
      step_pair = StepPair.new(@group, "foo") do
        up {}
      end
      step_pair.should_not be_valid
    end
    it "should return true if neither up_step and down_step is nil" do
      step_pair = StepPair.new(@group, "foo") do
        up {}
        down {}
      end
      step_pair.should be_valid
    end
  end
end
