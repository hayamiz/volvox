require 'spec_helper'

describe DiariesController do
  render_views

  describe "GET 'new'" do
    describe "for non-signed-in users" do
      it "should redirect to sign in form" do
        post :create, :diary => @attr
        response.should redirect_to(signin_path)
      end
    end

    describe "for signed-in users" do
      before(:each) do
        @user = test_sign_in(Factory(:user))
      end

      it "should have the right title" do
        get :new
        response.should have_selector("title", :content => "Create a new diary")
      end

      it "should have form fields" do
        get :new
        response.should have_selector("input[type='text'][name='diary[title]']")
        response.should have_selector("input[type='text'][name='diary[desc]']")
      end
    end
  end

  describe "POST 'create'" do
    before(:each) do
      @attr = {
        :title => "Test diary",
        :desc => "This is a test diary"
      }
    end

    describe "for non-signed-in users" do
      it "should redirect to sign in form" do
        post :create, :diary => @attr
        response.should redirect_to(signin_path)
      end
    end

    describe "for signed-in users" do
      before(:each) do
        @user = test_sign_in(Factory(:user))
      end

      describe "failure" do
        it "should not create an instance with invalid inputs" do
          lambda do
            attr = { :title => "", :desc => "" }
            post :create, :diary => attr
          end.should_not change(Diary, :count)
        end
      end

      describe "success" do
        it "should create a Diary instance with valid inputs" do
          lambda do
            post :create, :diary => @attr
          end.should change(Diary, :count).by(1)
        end

        it "should redirect to the root page" do
          post :create, :diary => @attr
          response.should redirect_to(root_path)
          flash[:success].should =~ /created/
        end

        it "should also create an Authorship instance with valid inputs" do
          lambda do
            post :create, :diary => @attr
          end.should change(Authorship, :count).by(1)
        end

        it "should correctly associate the user with the diary" do
          post :create, :diary => @attr
          @user.reload
          @user.diaries.should be_include(assigns(:diary))
        end
      end
    end
  end

  describe "GET 'edit'" do
    before(:each) do
      @diary = Factory(:diary)
    end

    describe "for non-signed-in users" do
      it "should redirect to sign in form" do
        get :edit, :id => @diary
        response.should redirect_to(signin_path)
      end
    end

    describe "for signed-in non-authors" do
      before(:each) do
        @user = test_sign_in(Factory(:user))
        @author = Factory(:user, :email => Factory.next(:email))
        @author.participate(@diary)
      end

      it "should redirect to sign in form" do
        get :edit, :id => @diary
        response.should redirect_to(signin_path)
      end
    end

    describe "for signed-in authors" do
      before(:each) do
        @user = test_sign_in(Factory(:user))
        @user.participate(@diary)
      end

      it "should have the right title" do
        get :edit, :id => @diary
        response.should have_selector("title", :content => "Edit the diary")
      end

      it "should have form fields" do
        get :edit, :id => @diary
        response.should have_selector("input[type='text'][name='diary[title]']")
        response.should have_selector("input[type='text'][name='diary[desc]']")
      end
    end
  end

  describe "PUT 'update'" do
    before(:each) do
      @diary = Factory(:diary)
      @attr = {
        :title => "New title",
        :desc => "I changed the title of this diary"
      }
    end

    describe "for non-signed-in users" do
      it "should redirect to sign in form" do
        put :update, :id => @diary, :diary => @attr
        response.should redirect_to(signin_path)
      end
    end

    describe "for signed-in non-authors" do
      before(:each) do
        @user = test_sign_in(Factory(:user))
        @author = Factory(:user, :email => Factory.next(:email))
        @author.participate(@diary)
      end

      it "should redirect to sign in form" do
        put :update, :id => @diary, :diary => @attr
        response.should redirect_to(signin_path)
      end
    end

    describe "for signed-in authors" do
      before(:each) do
        @user = test_sign_in(Factory(:user))
        @user.participate(@diary)
      end

      describe "failure" do
        it "should not update the attributes with empty title" do
          put :update, :id => @diary, :diary => @attr.merge(:title => "")
          @diary.reload
          @attr.each do |key, value|
            @diary[key].should_not == value
          end
        end

        it "should render the edit page" do
          put :update, :id => @diary, :diary => @attr.merge(:title => "")
          response.should render_template("diaries/edit")
        end
      end

      describe "success" do
        it "should update the attributes" do
          put :update, :id => @diary, :diary => @attr
          @diary.reload
          @attr.each do |key, value|
            @diary[key].should == value
          end
        end

        it "should redirect to the diary with flash message" do
          put :update, :id => @diary, :diary => @attr
          response.should redirect_to(@diary)
          flash[:success].should =~ /updated/i
        end
      end
    end
  end

  describe "GET 'show'" do
    before(:each) do
      @diary = Factory(:diary)
    end

    it "should have the right title" do
      get :show, :id => @diary
      response.should have_selector("title", :content => @diary.title)
    end

    it "should have the title and the description" do
      get :show, :id => @diary
      response.should have_selector("h1", :content => @diary.title)
      response.should have_selector("p", :content => @diary.desc)
    end

    it "should not have the link to the edit page" do
      get :show, :id => @diary
      response.should_not have_selector("a",
                                        :href => edit_diary_path(@diary),
                                        :content => "Edit")
    end

    describe "for authors" do
      before(:each) do
        @user = test_sign_in(Factory(:user))
        @user.participate(@diary)
      end

      it "should have the link to new entry page" do
        get :show, :id => @diary
        response.should have_selector("a",
                                      :href => new_diary_entry_path(@diary),
                                      :content => "Write a new entry")
      end

      it "should have the link to the edit page" do
        get :show, :id => @diary
        response.should have_selector("a",
                                      :href => edit_diary_path(@diary),
                                      :content => "Edit")
      end
    end

    describe "for non-existing diaries" do
      it "should return 404 code" do
        get :show, :id => @diary.id + 1
        response.response_code.should == 404
      end
    end

    describe "with some entries" do
      before(:each) do
        @entries = Array.new
        5.times do |n|
          entry = Factory(:entry,
                          :diary => @diary,
                          :title => "The #{(n+1).ordinalize} entry",
                          :content => Faker::Lorem.paragraphs(3))
          @entries.push(entry)
        end
      end

      it "should have entries displayed" do
        get :show, :id => @diary
        @entries.each do |entry|
          response.should have_selector("h2", :content => entry.title)
          # response.should have_selector("section", :content => entry.content)
        end
      end

      it "should have links to entries" do
        get :show, :id => @diary
        @entries.each do |entry|
          response.should have_selector("a",
                                        :href => diary_entry_path(@diary, entry),
                                        :content => entry.title)
          # response.should have_selector("section", :content => entry.content)
        end
      end
    end

    describe "with many entries" do
      it "should have pagination links" do
        pending "to be implemented"
      end
    end
  end

  it "should have deletion" do
    pending "deletion"
  end
end
