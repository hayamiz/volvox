require 'spec_helper'

describe Authorship do
  before(:each) do
    @user = Factory(:user)
    @diary = Factory(:diary)
    @authorship = @user.authorships.build(:diary_id => @diary)
  end

  it "should create an instance" do
    @authorship.save!
  end

  describe "validation" do
    it "should not create an instance without user_id" do
      @authorship.user_id = nil
      @authorship.should_not be_valid
    end

    it "should not create an instance without diary_id" do
      @authorship.diary_id = nil
      @authorship.should_not be_valid
    end

    it "should not create an instance with invalid diary_id" do
      @authorship.diary_id = @diary.id + 1
      lambda do
        @authorship.save
      end.should_not change(Authorship, :count)
    end
  end
end
# == Schema Information
#
# Table name: authorships
#
#  id         :integer         not null, primary key
#  user_id    :integer
#  diary_id   :integer
#  created_at :datetime
#  updated_at :datetime
#

