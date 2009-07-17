require File.join(File.dirname(__FILE__), %w[.. spec_helper])

include Sqrbl

describe Step do
  before(:each) do
    @pair = mock('StepPair')
  end

  it "should evaluate the block in its own context" do
    step = Step.new(@pair, :skip_block_evaluation => true) do
      hello_world()
    end
    step.should_receive(:hello_world)
    step.send(:evaluate_block!)
  end

  it "should delegate method_missing calls back to the step_pair object" do
    @pair.should_receive(:goodbye_world)
    step = Step.new(@pair) do
      goodbye_world()
    end
  end

  it "methods defined in the step's block should become available as methods on the Step instance" do
    step = Step.new(@pair) do
      def hello_world
        "Hello, world!"
      end
    end
    step.should respond_to(:hello_world)
    step.hello_world.should == "Hello, world!"
  end

  describe "when #todo is called" do
    it "should create a Todo object that saves the message" do
      step = Step.new(@pair) { todo 'foo' }
      step.todos.map(&:message).should == ['foo']
    end

    it "should create a Todo object that saves the location of the #todo call" do
      step = Step.new(@pair) { todo 'foo' }; line_num = __LINE__
      step.todos.first.location.should == [__FILE__, line_num].join(':')
    end
  end
end
