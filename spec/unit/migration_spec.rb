require File.join(File.dirname(__FILE__), %w[.. spec_helper])

include Sqrbl

describe Migration do
  describe "A new migration" do
    it "should know the file that created it" do
      mig = Migration.new
      mig.creating_file.should == File.expand_path(__FILE__)
    end
  end

  describe "A migration built with Migration.build" do
    it "should still know the file that created it" do
      mig = Migration.build {}
      mig.creating_file.should == File.expand_path(__FILE__)
    end

    describe "when the block calls #group once" do
      it "should have one group with the proper description" do
        mig = Migration.build do
          group "first group" do
            'hello world'
          end
        end
        mig.groups.all? { |group| group.should be_kind_of(Group) }
        mig.groups.map(&:description).should == ['first group']
      end
    end

    describe "when the block calls #group twice" do
      it "should have two group with the proper descriptions" do
        mig = Migration.build do
          group "first group" do
            'hello world'
          end
          group "second group" do
            'goodbye world'
          end
        end
        mig.groups.all? { |group| group.should be_kind_of(Group) }
        mig.groups.map(&:description).should == ['first group', 'second group']
      end
    end

    it "should pass itself as a dependency to any group it builds" do
      mig = Migration.build do
        group("first group"    ) { '' }
        group("second group"   ) { '' }
        group("group the third") { '' }
      end

      mig.groups.all? { |group| group.migration.should == mig }
    end
  end

  describe "when #todo is called" do
    it "should create a Todo object that saves the message" do
      mig = Migration.build { todo 'foo' }
      mig.todos.map(&:message).should == ['foo']
    end

    it "should create a Todo object that saves the location of the #todo call" do
      mig = Migration.build { todo 'foo' }; line_num = __LINE__
      mig.todos.first.location.should == [__FILE__, line_num].join(':')
    end
  end
end
