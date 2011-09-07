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
end
