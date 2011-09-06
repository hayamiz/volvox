require 'spec_helper'

# == Schema Information
#
# Table name: users
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime
#  updated_at :datetime
#

describe User do
  before(:each) do
    @attr = {
      :name			=> "Test User",
      :email			=> "test@example.com",
      :password			=> "hogehoge",
      :password_confirmation	=> "hogehoge"
    }
  end

  it "should create an instance with valid attrs" do
    User.create!(@attr)
  end

  it "should require a name" do
    User.new(@attr.merge(:name => "")).should_not be_valid
  end

  it "should require an email" do
    User.new(@attr.merge(:email => "")).should_not be_valid
  end

  it "should require a password" do
    attr = @attr.merge(:password => "",
                       :password_confirmation => "")
    User.new(attr).should_not be_valid
  end

  it "should require passwords match" do
    attr = @attr.merge(:password => "foobar",
                       :password_confirmation => "invalid")
    User.new(attr).should_not be_valid
  end

  it "should require a long enough password" do
    attr = @attr.merge(:password => "short",
                       :password_confirmation => "short")
    User.new(attr).should_not be_valid

    attr = @attr.merge(:password => "sogood",
                       :password_confirmation => "sogood")
    User.new(attr).should be_valid
  end

  it "should reject too long name" do
    long_name = "a" * 256
    User.new(@attr.merge(:name => long_name)).should_not be_valid
  end

  it "should accept names with valid length" do
    User.new(@attr).should be_valid
    name = "a" * 255
    User.new(@attr.merge(:name => name)).should be_valid
  end

  describe "authentication" do
    before(:each) do
      @user = Factory(:user)
    end

    describe "authenticate method" do
      it "should return nil for non-existent users" do
        User.authenticate("invalid@example.com", "").should be_nil
      end

      it "should return nil on email/password mismatch" do
        User.authenticate(@user.email, "").should be_nil
      end

      it "should return an User instance on email/password match" do
        User.authenticate(@user.email, @user.password).should == @user
      end
    end
  end
end
