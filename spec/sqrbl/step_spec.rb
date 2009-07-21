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

    it "should prepend its argument with '--> TODO ([file], line [line #]):' and put it in #output" do
      line_num = 0
      step = Step.new(@pair) do
        todo 'Fix a terrible issue'; line_num = __LINE__
      end
      step.output.should =~ /^--> TODO /
      step.output.should include(__FILE__)
      step.output.should =~ Regexp.new("line #{line_num}")
      step.output.should include('Fix a terrible issue')
    end
  end

  describe "when #comment is called" do
    it "should prepend its argument with '-- ' and put it in #output" do
      message = "Here's something you should probably be aware of."
      step = Step.new(@pair) { comment(message) }
      step.output.should =~ Regexp.new('^-- ' + message)
    end
  end

  describe "when #block_comment is called" do
    it "should surround its argument with /* and */ on newlines and put the whole thing in #output" do
      message = "Here's something you should probably be aware of."
      step = Step.new(@pair) { block_comment(message) }
      step.output.should =~ /^\/\*/
      step.output.should =~ Regexp.new('^    ' + message)
      step.output.should =~ /^\*\//
    end

    describe "and given a string with extra spaces (as, e.g., a heredoc)" do
      it "should unindent the argument before putting it in #output" do
        step = Step.new(@pair) do
          block_comment <<-EOF
            Foo.
          EOF
        end
        step.output.should =~ /^    Foo./
      end
    end
  end

  describe "when #action is called with a string and a block" do
    before(:each) do
      @step = Step.new(@pair) do
        action "Do something" do
          <<-EOF
            Hello world!
          EOF
        end
      end
    end

    it "should treat the string as a comment" do
      @step.output.should =~ /^-- Do something/
    end

    it "should unindent the return value from the block and put it in #output" do
      @step.output.should =~ /^Hello world!/
    end
  end
end
