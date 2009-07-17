require File.join(File.dirname(__FILE__), %w[.. spec_helper])

include Sqrbl

describe Group do
  before(:each) do
    @mig = mock('Migration')
  end

  it "should evaluate the block in its own context" do
    group = Group.new(@mig, "foo", :skip_block_evaluation => true) do
      hello_world()
    end
    group.should_receive(:hello_world)
    group.send(:evaluate_block!)
  end

  it "should delegate method_missing calls back to the migration object" do
    @mig.should_receive(:goodbye_world)
    group = Group.new(@mig, "foo") do
      goodbye_world()
    end
  end

  it "methods defined in the group block should become available as methods on the Group instance" do
    group = Group.new(@mig, "foo") do
      def hello_world
        "Hello, world!"
      end
    end
    group.should respond_to(:hello_world)
    group.hello_world.should == "Hello, world!"
  end

  describe "when #todo is called" do
    it "should create a Todo object that saves the message" do
      msg = 'Frobnicate the doohickey'
      group = Group.new(@mig, "foo") { todo msg }
      group.todos.map(&:message).should == [msg]
    end

    it "should create a Todo object that saves the location of the #todo call" do
      msg = 'Frobnicate the doohickey'
      group = Group.new(@mig, "foo") { todo msg }; expected_calling_line = __LINE__
      group.todos.first.location.should == [__FILE__, expected_calling_line].join(':')
    end
  end

  describe "when #step is called" do
    it "should create a StepPair object and pass it the group, the description, and the block arg" do
      test_self = self
      group = Group.new(@mig, "foo") do
        StepPair.should_receive(:new).with(self, 'do something').and_yield # Look weird?  See ./README.txt
        step('do something') {}
      end
    end
  end

  describe :valid? do
    it "should return false if steps is empty" do
      group = Group.new(@mig, "foo") {}
      group.should_not be_valid
    end
    it "should return true if steps is not empty" do
      group = Group.new(@mig, "foo") { step("foo") {} }
      group.should be_valid
    end
  end

end
