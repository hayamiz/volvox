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

  describe "GET 'edit'" do
    before(:each) do
      @user = test_sign_in(Factory(:user))
    end

    describe "for non authorized users" do
      it "should deny access by others" do
        wrong_user = test_sign_in(Factory(:user, :email => "mallory@example.com"))
        get :edit, :id => @user
        response.should redirect_to(root_path)
      end
    end

    describe "for authorized users" do
      it "should have the right title" do
        get :edit, :id => @user
        response.should have_selector("title", :content => "Setting")
      end

      it "should have required fields" do
        get :edit, :id => @user
        response.should have_selector("input[name='user[name]'][type='text']",
                                      :value => @user.name)
        response.should have_selector("input[name='user[email]'][type='text']",
                                      :value => @user.email)
        response.should have_selector("input[name='user[password]'][type='password']")
        response.should have_selector("input[name='user[password_confirmation]'][type='password']")
      end
    end
  end

  describe "PUT 'update'" do
    before(:each) do
      @user = test_sign_in(Factory(:user))
      @other = Factory(:user, :email => "other@example.com")
      @attr = {
        :name => "New Name",
        :email => "new" + @user.email,
        :password => @user.password,
        :password_confirmation => @user.password
      }
    end

    it "should not update an instance with taken email" do
      attr = @attr.merge(:email => @other.email)
      put :update, :id => @user, :user => attr
      response.should render_template("users/edit")
      @user.reload
      @user.name.should_not == attr[:name]
      @user.email.should_not == attr[:email]
    end

    it "should update an instance without password change" do
      pending "considering about changing the way of auth."
      attr = @attr.merge(:password => "", :password_confirmation => "")
      put :update, :id => @user, :user => attr
      response.should redirect_to(@user)
      @user.reload
      @user.name.should == @attr[:name]
      @user.email.should == @attr[:email]
    end

    it "should update an instance" do
      put :update, :id => @user, :user => @attr
      response.should redirect_to(@user)
      @user.reload
      @user.name.should == @attr[:name]
      @user.email.should == @attr[:email]
    end
  end
end
