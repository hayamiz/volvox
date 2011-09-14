require 'spec_helper'

describe OptRecord do
  it "should respond to :time" do
    OptRecord.new.should respond_to(:time)
  end

  it "should respond to :value" do
    OptRecord.new.should respond_to(:value)
  end

  it "should respond to :diary_id" do
    OptRecord.new.should respond_to(:diary_id)
  end

  describe "accessibility" do
    it "should allow access to time" do
      t = Time.now
      OptRecord.new(:time => t).time.should == t
    end

    it "should allow access to value" do
      value = "hogehoge"
      OptRecord.new(:value => value).value.should == value
    end

    it "should not allow access to diary_id" do
      id = 123
      OptRecord.new(:diary_id => id).diary_id.should_not == id
    end
  end

  describe "diary association" do
    it "should respond to :diary" do
      OptRecord.new.should respond_to(:diary)
    end

    it "should have the right diary" do
      diary = Factory(:diary)
      rec = diary.opt_records.build
      rec.diary.should == diary
    end
  end

  describe "validation" do
    before(:each) do
      @diary = Factory(:diary)
      @attr = {
        :time => Time.at(0),
        :value => Marshal.dump(:foo => 10, :bar => "a")
      }
    end

    it "should create an instance" do
      @diary.opt_records.create!(@attr)
    end

    it "should require time" do
      @diary.opt_records.build(@attr.merge(:time => nil)).should_not be_valid
    end

    it "should require value" do
      @diary.opt_records.build(@attr.merge(:value => nil)).should_not be_valid
      @diary.opt_records.build(@attr.merge(:value => "")).should_not be_valid
    end
  end
end
