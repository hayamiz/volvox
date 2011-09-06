require 'spec_helper'

describe "Layouts" do
  describe "navigation links" do
    it "should have Home link" do
      visit root_path
      response.should have_selector("a",
                                    :href => root_path,
                                    :content => "Home")
    end

    describe "for non-signed-in users" do
      it "should have Singin link" do
        visit root_path
        response.should have_selector("a",
                                      :href => signin_path,
                                      :content => "Sign in")
      end
    end

    describe "for signed-in users" do
      before(:each) do
        @user = Factory(:user)
        integration_sign_in(@user)
      end

      it "should not have Signin link" do
        visit root_path
        response.should_not have_selector("a",
                                          :href => signin_path,
                                          :content => "Sign in")
      end

      it "should have Signout link" do
        visit root_path
        response.should have_selector("a",
                                      :href => signout_path,
                                      :content => "Sign out")
      end

      it "should have Setting link" do
        visit root_path
        response.should have_selector("a",
                                      :href => edit_user_path(@user),
                                      :content => "Setting")
      end
    end
  end
end
