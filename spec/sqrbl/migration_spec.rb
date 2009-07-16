require File.join(File.dirname(__FILE__), %w[.. spec_helper])

include Sqrbl

describe Migration do
  describe "A migration built with Migration.build" do
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

end
