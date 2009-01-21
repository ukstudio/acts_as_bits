require File.dirname(__FILE__) + '/spec_helper'

describe ActsAsBits do
  describe " should mark dirty" do
    before(:each) do
      @obj = Mixin.create!(:flags=>"00")
    end

    it "when value is changed by setter" do
      @obj.flags                 # create string object first
      @obj.changed?.should == false
      @obj.admin = true
      @obj.changed?.should == true
      @obj.changes.should == {"flags"=>["00", "10"]}
    end

    it "when massive assignment" do
      @obj.flags                 # create string object first
      @obj.changed?.should == false
      @obj.attributes = {:admin => true}
      @obj.changed?.should == true
      @obj.changes.should == {"flags"=>["00", "10"]}
    end
  end
end
