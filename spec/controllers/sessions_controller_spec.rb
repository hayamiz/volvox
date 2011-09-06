require 'spec_helper'

describe SessionsController do
  render_views

  describe "GET 'new'" do
    it "should have the right title" do
      get :new
      response.should have_selector("title", :content => "Sign in")
    end

    it "should have fields" do
      get :new
      response.should have_selector("input[name='session[email]'][type='text']")
      response.should have_selector("input[name='session[password]'][type='password']")
    end
  end

  describe "POST 'create'" do
    before(:each) do
      @user = Factory(:user)
      @attr = {
        :email => @user.email,
        :password => @user.password
      }
    end

    describe "failure" do
      it "should deny invalid inputs" do
        post :create, :session => { :email => "", :password => "" }
        response.should render_template("sessions/new")
      end

      it "should deny access on email/password mismatch" do
        post :create, :session => @attr.merge(:password => @user.password+"boo")
        response.should render_template("sessions/new")
      end
    end

    describe "success" do
      it "should allow signing in with correct email/password" do
        post :create, :session => @attr
        response.should redirect_to(user_path(@user))
      end
    end
  end

  describe "DELETE 'destroy'" do
    it "should sign a user out" do
      user = test_sign_in(Factory(:user))
      delete :destroy
      controller.should_not be_signed_in
      response.should redirect_to(root_path)
    end
  end
end
