require 'spec_helper'

describe PagesController do
  render_views

  describe "home" do
    it "should have link to sign up page" do
      get :home
      response.should have_selector("a",
                                    :href => signup_path,
                                    :content => "Sign up")
    end
  end
end
