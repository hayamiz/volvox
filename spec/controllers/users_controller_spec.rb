require 'spec_helper'

describe UsersController do
  render_views

  describe "GET 'new'" do
    it "should have the right title" do
      get :new
      response.should have_selector("title", :content => "Sign up")
    end

    it "should have required fields" do
      get :new
      response.should have_selector("input[name='user[name]'][type='text']")
      response.should have_selector("input[name='user[email]'][type='text']")
      response.should have_selector("input[name='user[password]'][type='password']")
      response.should have_selector("input[name='user[password_confirmation]'][type='password']")
    end
  end

  describe "POST 'create'" do
    before(:each) do
      @attr = {
        :name => "Example User",
        :email => "example@example.com",
        :password => "hogehoge",
        :password_confirmation => "hogehoge"
      }
    end

    describe "failure" do
      before(:each) do
        @attr.merge!(:name => "", :email => "")
      end
      it "should reject invalid inputs" do
        lambda do
          post :create, :user => @attr
        end.should_not change(User, :count)
      end

      it "should reject invalid inputs" do
        post :create, :user => @attr
        response.should render_template("users/new")
      end
    end

    describe "success" do
      it "should create an instance with given valid inputs" do
        lambda do
          post :create, :user => @attr
        end.should change(User, :count).by(1)
      end

      it "should redirect to the user show page" do
        post :create, :user => @attr
        response.should redirect_to(user_path(assigns(:user)))
      end
    end
  end

  describe "GET 'show'" do
    before(:each) do
      @user = Factory(:user)
    end

    describe "for non-existing users" do
      it "should get 404" do
        get :show, :id => 2
        response.response_code.should == 404
      end
    end

    describe "for existing users" do
      it "should be successful" do
        get :show, :id => @user
        response.should be_success
      end

      it "should have user's name" do
        get :show, :id => @user
        response.should have_selector("h1", :content => @user.name)
      end
    end
  end
end
