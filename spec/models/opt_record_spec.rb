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
      @column1 = @diary.opt_columns.create!(:name => "Test column 1",
                                            :col_type => OptColumn::COL_INTEGER)
      @column2 = @diary.opt_columns.create!(:name => "Test column 2",
                                            :col_type => OptColumn::COL_FLOAT)
      @attr = {
        :time => Time.at(0),
        :value => {@column1.ckey => 10, @column2.ckey => 1.0}
      }
    end

    it "should create an instance with valid value" do
      lambda do
        @diary.opt_records.create!(@attr)
      end.should change(OptRecord, :count).by(1)
    end

    it "should allow valid input" do
      @diary.opt_records.build(@attr).should be_valid
    end

    it "should require time" do
      @diary.opt_records.build(@attr.merge(:time => nil)).should_not be_valid
    end

    it "should require value" do
      @diary.opt_records.build(@attr.merge(:value => nil)).should_not be_valid
      @diary.opt_records.build(@attr.merge(:value => "")).should_not be_valid
    end

    it "should require Hash as :value attribute" do
      @diary.opt_records.build(@attr.merge(:value => 1)).should_not be_valid
      @diary.opt_records.build(@attr.merge(:value => "foo")).should_not be_valid
      @diary.opt_records.build(@attr.merge(:value => [1,2,3])).should_not be_valid
      @diary.opt_records.build(@attr.merge(:value => {})).should_not be_valid
    end

    it "should allow only existing column as hash keys of :value attribute" do
      @diary.opt_records.build(@attr.merge(:value => {:foo => "bar"})).should_not be_valid
    end

    it "should check types of each value in :value attribute" do
      @diary.opt_records.build(@attr.merge(:value => {@column1.ckey => "foo"})).should_not be_valid
    end
  end

  describe "value method" do
    before(:each) do
      @diary = Factory(:diary)
      @column1 = @diary.opt_columns.create!(:name => "Test column 1",
                                            :col_type => OptColumn::COL_INTEGER)
      @column2 = @diary.opt_columns.create!(:name => "Test column 2",
                                            :col_type => OptColumn::COL_FLOAT)
      @column3 = @diary.opt_columns.create!(:name => "Test column 3",
                                            :col_type => OptColumn::COL_STRING)
      @value = {
        @column1.ckey => 10,
        @column2.ckey => 1.0,
        @column3.ckey => "hello world"
      }
      @record = @diary.opt_records.create!(:time => Time.at(0),
                                           :value => @value)
    end

    it "should respond to :value" do
      @record.should respond_to(:value)
    end

    it "should return the right value" do
      @record.value.should == @value
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

    it "should respond to 'column key' methods" do
      @columns.each do |col|
        @record.should respond_to(col.ckey)
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

