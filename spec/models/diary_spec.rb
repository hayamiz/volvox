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
end

