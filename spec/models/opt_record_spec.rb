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

  describe "dummy method for dynamic OptColumn" do
    before(:each) do
      @diary = Factory(:diary)
      @entry = Factory(:entry, :diary => @diary)
      @columns = [Factory(:opt_column, :diary => @diary),
                  Factory(:opt_column, :name => "Fat", :diary => @diary)]
      @record = @diary.opt_records.build
    end

    it "should respond to c* methods" do
      @columns.each do |col|
        @record.should respond_to(:c1)
        @record.should respond_to("c#{col.id}".to_sym)
      end
    end

    it "should not respond to non-existing c* methods" do
      10.times do |n|
        @record.should_not respond_to("c#{(100000*rand).to_i}".to_sym)
      end
    end
  end
end
# == Schema Information
#
# Table name: opt_records
#
#  id         :integer         not null, primary key
#  time       :time
#  value      :string(255)
#  diary_id   :integer
#  created_at :datetime
#  updated_at :datetime
#

