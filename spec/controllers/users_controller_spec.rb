require 'spec_helper'

describe UsersController do
  render_views

  describe "session functions" do
    before(:each) do
      @user = Factory(:user)
    end

    describe "current_user method" do
      it "should return nil if no one signed in" do
        controller.current_user.should be_nil
      end
    end

    describe "current_user? method" do
      it "should return true for current user" do
        test_sign_in(@user)
        controller.current_user?(@user).should be_true
      end

      it "should return false for others" do
        test_sign_in(@user)
        other = Factory(:user, :email => Factory.next(:email))
        controller.current_user?(other).should be_false
      end
    end
  end

  describe "GET 'new'" do
    it "should have the right title" do
      get :new
      response.should have_selector("title", :content => t('users.new.title'))
    end

    it "should have required fields" do
      get :new
      response.should have_selector("input[name='user[name]'][type='text']")
      response.should have_selector("input[name='user[email]'][type='email']")
      response.should have_selector("input[name='user[password]'][type='password']")
      response.should have_selector("input[name='user[password_confirmation]']" \
                                    "[type='password']")
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

      describe "with some diaries" do
        before(:each) do
          @diary1 = Factory(:diary)
          @diary2 = Factory(:diary, :title => Faker::Lorem.sentence(5))
          @user.participate(@diary1)
          @user.participate(@diary2)
        end

        it "should list user's diaries" do
          get :show, :id => @user
          [@diary1, @diary2].each do |diary|
            response.should have_selector("a",
                                          :content => diary.title,
                                          :href => diary_path(diary))
          end
        end
      end

      describe "with many diaries" do
        before(:each) do
          @diaries = []
          50.times do |n|
            diary = Factory(:diary,
                            :title => "Diary #{n.ordinalize}",
                            :desc => Faker::Lorem.sentence(10))
            @user.participate(diary)
            @diaries.push(diary)
          end
        end
        
        it "should page pagination links" do
          response.should_not have_selector("a",
                                            :href => user_path(@user, :page => 2),
                                            :content => "Next")
        end
      end
    end

    describe "invitation of a diary authorship" do
      before(:each) do
        @other = Factory(:user,
                         :name => Faker::Name.name,
                         :email => Factory.next(:email))
        @diary = Factory(:diary)
        @user.participate(@diary)
        test_sign_in(@user)
      end

      it "should have a link for invitation of a diary authorship" do
        get :show, :id => @other
        response.should have_selector("form[action='#{authorships_path}']")
      end

      describe "the user is already an author" do
        before(:each) do
          @other.participate(@diary)
        end

        it "should not have a link for invitation" do
          get :show, :id => @other
          response.should_not have_selector("form[action='#{authorships_path}']")
        end
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
        response.should have_selector("title", :content => t('users.edit.title'))
      end

      it "should have required fields" do
        get :edit, :id => @user
        response.should have_selector("input[name='user[name]'][type='text']",
                                      :value => @user.name)
        response.should have_selector("input[name='user[email]'][type='email']",
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
