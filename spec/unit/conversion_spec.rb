require File.join(File.dirname(__FILE__), %w[.. spec_helper])

include Sqrbl

describe Conversion do
  describe "A new conversion" do
    it "should know the file that created it" do
      cvn = Conversion.new
      cvn.creating_file.should == File.expand_path(__FILE__)
    end
  end

  describe "A conversion built with Conversion.build" do
    it "should still know the file that created it" do
      cvn = Conversion.build {}
      cvn.creating_file.should == File.expand_path(__FILE__)
    end

    describe "when the block calls #group once" do
      it "should have one group with the proper description" do
        cvn = Conversion.build do
          group "first group" do
            'hello world'
          end
        end
        cvn.groups.all? { |group| group.should be_kind_of(Group) }
        cvn.groups.map(&:description).should == ['first group']
      end
    end

    describe "when the block calls #group twice" do
      it "should have two group with the proper descriptions" do
        cvn = Conversion.build do
          group "first group" do
            'hello world'
          end
          group "second group" do
            'goodbye world'
          end
        end
        cvn.groups.all? { |group| group.should be_kind_of(Group) }
        cvn.groups.map(&:description).should == ['first group', 'second group']
      end
    end

    it "should pass itself as a dependency to any group it builds" do
      cvn = Conversion.build do
        group("first group"    ) { '' }
        group("second group"   ) { '' }
        group("group the third") { '' }
      end

      cvn.groups.all? { |group| group.conversion.should == cvn }
    end
  end

  describe "when #todo is called" do
    it "should create a Todo object that saves the message" do
      cvn = Conversion.build { todo 'foo' }
      cvn.todos.map(&:message).should == ['foo']
    end

    it "should create a Todo object that saves the location of the #todo call" do
      cvn = Conversion.build { todo 'foo' }; line_num = __LINE__
      cvn.todos.first.location.should == [__FILE__, line_num].join(':')
    end
  end
end
