require 'spec_helper'

describe Entry do
  describe "validation" do
    before(:each) do
      @diary = Factory(:diary)
      @attr = {
        :title => "The First Entry of my diary",
        :content => "Hello, my friend.",
      }
    end

    it "should create an instance" do
      @diary.entries.create!(@attr)
    end

    it "should reject an empty title" do
      @diary.entries.build(@attr.merge(:title => "")).should_not be_valid
    end

    it "should reject an empty content" do
      @diary.entries.build(@attr.merge(:content => "")).should_not be_valid
    end

    it "should reject a too long title" do
      @diary.entries.build(@attr.merge(:title => "a"*256)).should_not be_valid
    end

    it "should accept a not so long title" do
      @diary.entries.build(@attr.merge(:title => "a"*255)).should be_valid
    end
  end

  describe "associations" do
    before(:each) do
      @diary = Factory(:diary)
      @entry = Factory(:entry, :diary => @diary)
    end

    it "should have a diary" do
      @entry.diary.should == @diary
    end
  end
end
# == Schema Information
#
# Table name: entries
#
#  id         :integer         not null, primary key
#  title      :string(255)
#  content    :text
#  created_at :datetime
#  updated_at :datetime
#  diary_id   :integer
#

