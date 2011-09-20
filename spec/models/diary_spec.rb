require 'spec_helper'

describe Diary do
  describe "validation" do
    before(:each) do
      @attr = {
        :title => "Test Diary",
        :desc => "This is a diary for testing."
      }
    end

    it "should create an instance" do
      Diary.create!(@attr)
    end

    it "should reject an empty title" do
      Diary.new(@attr.merge(:title => "")).should_not be_valid
    end

    it "should reject a too long title" do
      Diary.new(@attr.merge(:title => "a" * 256)).should_not be_valid
    end

    it "should accept an empty description" do
      Diary.new(@attr.merge(:desc => "")).should be_valid
    end
  end

  describe "association with Authorship" do
    before(:each) do
      @user = Factory(:user)
      @diary = Factory(:diary)
      @authorship = @user.authorships.create(:diary_id => @diary)
    end

    it "should respond to reverse_authorships method" do
      @diary.should respond_to(:reverse_authorships)
    end

    it "should respond to authors method" do
      @diary.should respond_to(:authors)
    end

    it "should have an author" do
      @diary.authors.should == [@user]
    end
  end

  describe "association with Entry" do
    before(:each) do
      @diary = Factory(:diary)
    end

    it "should respond to entries" do
      @diary.should respond_to(:entries)
    end

    it "should have no entires at first" do
      @diary.entries.should be_empty
    end

    it "should have a entry" do
      entry1 = Factory(:entry, :diary => @diary)
      @diary.entries.should == [entry1]
    end

    it "should have entiries sorted" do
      entry1 = Factory(:entry, :diary => @diary, :date => 1.day.ago.to_date)
      entry2 = Factory(:entry, :diary => @diary, :date => 2.day.ago.to_date)
      entry3 = Factory(:entry, :diary => @diary, :date => Time.now.to_date)
      @diary.entries.should == [entry3, entry1, entry2]
    end
  end

  describe "opt_columns association" do
    before(:each) do
      @diary = Factory(:diary)
    end

    it "should respond to opt_columns" do
      @diary.should respond_to(:opt_columns)
    end

    it "should be an array of OptColumn instances" do
      @diary.opt_columns.create!(:name => "Test column 1",
                                 :col_type => OptColumn::COL_INTEGER)
      @diary.opt_columns.create!(:name => "Test column 2",
                                 :col_type => OptColumn::COL_FLOAT)
      @diary.opt_columns.each do |col|
        col.is_a?(OptColumn).should be_true
      end
    end

    it "should delete columns on diary deletion" do
      col1 = @diary.opt_columns.create!(:name => "Test column 1",
                                        :col_type => OptColumn::COL_INTEGER)
      col2 = @diary.opt_columns.create!(:name => "Test column 2",
                                        :col_type => OptColumn::COL_FLOAT)
      col_ids = [col1.id, col2.id]
      @diary.destroy
      col_ids.each do |col_id|
        OptColumn.find_by_id(col_id).should be_nil
      end
    end
  end

  describe "opt_records association" do
    before(:each) do
      @diary = Factory(:diary)
      @col1 = @diary.opt_columns.create!(:name => "test1", :col_type => OptColumn::COL_INTEGER)
      @col2 = @diary.opt_columns.create!(:name => "test2", :col_type => OptColumn::COL_INTEGER)
      @rec1 = @diary.opt_records.create!(:time => Time.now,
                                         :value => {@col1.ckey => 1})
      @rec2 = @diary.opt_records.create!(:time => Time.now,
                                         :value => {@col2.ckey => 2})
    end

    it "should respond to :opt_records" do
      @diary.should respond_to(:opt_records)
    end

    it "should be an array of OptRecord" do
      @diary.opt_records.is_a?(Array).should be_true
      @diary.opt_records.each do |record|
        record.is_a?(OptRecord).should be_true
      end
    end

    it "should delete records on deletion" do
      @diary.destroy
      [@rec1, @rec2].each do |rec|
        OptRecord.find_by_id(rec.id).should be_nil
      end
    end
  end
end

# == Schema Information
#
# Table name: diaries
#
#  id         :integer         not null, primary key
#  title      :string(255)
#  desc       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

