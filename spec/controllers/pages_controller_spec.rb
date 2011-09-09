require 'spec_helper'

describe PagesController do
  render_views

  describe "home" do
    describe "for non-signed-in users" do
      it "should have link to sign up page" do
        get :home
        response.should have_selector("a",
                                      :href => signup_path,
                                      :content => "Sign up")
      end
    end

    describe "for signed-in users" do
      before(:each) do
        @user = test_sign_in(Factory(:user))
      end

      it "should redirect to user's page" do
        get :home
        response.should redirect_to(@user)
      end
    end
  end
end
