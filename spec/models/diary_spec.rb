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

