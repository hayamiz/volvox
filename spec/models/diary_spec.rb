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

  describe "associations" do
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
      entry1 = Factory(:entry, :diary => @diary, :created_at => 1.day.ago)
      entry2 = Factory(:entry, :diary => @diary, :created_at => Time.now)
      @diary.entries.should == [entry2, entry1]
    end
  end
end
