require 'spec_helper'

describe Entry do

  describe "attributes" do
    before(:each) do
      @entry = Entry.new
    end

    it("should respond to date")	{ @entry.should respond_to(:date) }
    it("should respond to temperature")	{ @entry.should respond_to(:temperature) }
    it("should respond to humidity")	{ @entry.should respond_to(:humidity) }
    it("should respond to action_feed")	{ @entry.should respond_to(:action_feed) }
    it("should respond to action_care")	{ @entry.should respond_to(:action_care) }
    it("should respond to pet_feces")	{ @entry.should respond_to(:pet_feces) }
    it("should respond to pet_physical"){ @entry.should respond_to(:pet_physical) }
    it("should respond to memo")	{ @entry.should respond_to(:memo) }

    describe "obsolete attributes" do
      it("should not respond to title"){ @entry.should_not respond_to(:title) }
      it("should not respond to content"){ @entry.should_not respond_to(:content)}
    end
  end

  describe "validation" do
    before(:each) do
      @diary = Factory(:diary)
      @attr = {
        :date => Date.today,
        :temperature => 25.5,
        :humidity => 60.0,
        :action_feed => "gave Brisky a lot",
        :action_care => "cleaned up the steel wheel",
        :pet_feces => "Many. black.",
        :pet_physical => "Kept Scratching her body. Itchy?",
        :memo => "nothing"
      }
    end

    it "should create an instance" do
      @diary.entries.create!(@attr)
    end

    it "should accept an entry with only date" do
      @diary.entries.build(:date => Date.new(2011, 9, 12)).should be_valid
    end

    it "should reject duplicated date" do
      @diary.entries.create!(@attr)
      entry = @diary.entries.build(:date => @attr[:date])
      entry.should_not be_valid
    end

    it "should allow duplicated date in different diary" do
      @diary.entries.create!(@attr)
      diary = Factory(:diary, :title => Faker::Lorem.sentence(5))
      diary.id.should_not == @diary.id
      entry = diary.entries.build(@attr.merge(:date => @attr[:date]))
      entry.should be_valid
    end

    it "should reject an empty date" do
      @diary.entries.build(@attr.merge(:date => nil)).should_not be_valid
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
#  id           :integer         not null, primary key
#  created_at   :datetime
#  updated_at   :datetime
#  diary_id     :integer
#  date         :date
#  temperature  :float
#  humidity     :float
#  action_feed  :text
#  action_care  :text
#  pet_feces    :text
#  pet_physical :text
#  memo         :text
#



