require 'spec_helper'

describe EntriesController do
  render_views

  describe "GET 'new'" do
    before(:each) do
      @diary = Factory(:diary)
    end

    describe "for non-signed-in users" do
      it "should redirect to signin page" do
        get :new, :diary_id => @diary
        response.should redirect_to(signin_path)
      end
    end

    describe "for non-author users" do
      before(:each) do
        @user = test_sign_in(Factory(:user))
      end

      it "should redirect to the diary page" do
        get :new, :diary_id => @diary
        response.should redirect_to(@diary)
      end

      it "should have flash message" do
        get :new, :diary_id => @diary
        flash[:failure] =~ /not an author/i
      end
    end

    describe "for authors" do
      before(:each) do
        @user = test_sign_in(Factory(:user))
        @user.participate(@diary)
      end

      it "should have the right title" do
        get :new, :diary_id => @diary
        response.should have_selector("title", :content => "New entry")
      end

      it "should have form fields" do
        get :new, :diary_id => @diary
        response.should have_selector("input[type='text'][name='entry[title]']")
        response.should have_selector("textarea[name='entry[content]']")
      end
    end
  end

  describe "GET 'edit'" do
    before(:each) do
      @diary = Factory(:diary)
      @entry = Factory(:entry, :diary => @diary)
    end

    describe "for non-signed-in users" do
      it "should redirect to signin page" do
        get :edit, :diary_id => @diary, :id => @entry
        response.should redirect_to(signin_path)
      end
    end

    describe "for non-author users" do
      before(:each) do
        @user = test_sign_in(Factory(:user))
      end

      it "should redirect to the diary page" do
        get :edit, :diary_id => @diary, :id => @entry
        response.should redirect_to(@diary)
      end

      it "should have flash message" do
        get :edit, :diary_id => @diary, :id => @entry
        flash[:failure] =~ /not an author/i
      end
    end

    describe "for authors" do
      before(:each) do
        @user = test_sign_in(Factory(:user))
        @user.participate(@diary)
      end

      it "should have the right title" do
        get :edit, :diary_id => @diary, :id => @entry
        response.should have_selector("title", :content => "Edit an entry")
      end

      it "should have form fields" do
        get :edit, :diary_id => @diary, :id => @entry
        response.should have_selector("input[type='text'][name='entry[title]']")
        response.should have_selector("textarea[name='entry[content]']")
      end
    end
  end

  describe "POST 'create'" do
    before(:each) do
      @diary = Factory(:diary)
      @attr = {
        :title => "A test entry",
        :content => "This is a test content",
      }
    end
    
    describe "for non-signed-in users" do
      it "should redirect to signin page" do
        post :create, :diary_id => @diary, :entry => @attr
        response.should redirect_to(signin_path)
      end
    end
    
    describe "for non-author users" do
      before(:each) do
        @user = test_sign_in(Factory(:user))
      end
      
      it "should not create an entry instance" do
        lambda do
          post :create, :diary_id => @diary, :entry => @attr
        end.should_not change(Entry, :count)
      end
      
      it "should redirect to the diary page" do
        post :create, :diary_id => @diary, :entry => @attr
        response.should redirect_to(@diary)
      end
      
      it "should have flash message" do
        post :create, :diary_id => @diary, :entry => @attr
        flash[:failure] =~ /not an author/i
      end
    end
    
    describe "for authors" do
      before(:each) do
        @user = test_sign_in(Factory(:user))
        @user.participate(@diary)
      end
      
      describe "failure" do
        it "should reject invalid diary_id" do
          lambda do
            post :create, :diary_id => @diary.id + 1, :entry => @attr
          end.should_not change(Entry, :count)
        end

        it "should redirect to root page if invalid diary_id" do
          post :create, :diary_id => @diary.id + 1, :entry => @attr
          response.should redirect_to(root_path)
        end

        it "should reject empty title" do
          lambda do
            post :create, :diary_id => @diary, :entry => @attr.merge(:title => "")
          end.should_not change(Entry, :count)
        end
        
        it "should reject empty content" do
          lambda do
            post :create, :diary_id => @diary, :entry => @attr.merge(:content => "")
          end.should_not change(Entry, :count)
        end

        it "should render new page with invalid inputs" do
          post :create, :diary_id => @diary, :entry => @attr.merge(:title => "")
          response.should render_template("entries/new")
        end
      end
      
      describe "success" do
        it "should create an Entry instance" do
          lambda do
            post :create, :diary_id => @diary, :entry => @attr
          end.should change(Entry, :count).by(1)
        end
        
        it "should redirect to entry page" do
          post :create, :diary_id => @diary, :entry => @attr
          response.should redirect_to([@diary, assigns(:entry)])
        end
        
        it "should have flash message" do
          post :create, :diary_id => @diary, :entry => @attr
          flash[:success].should =~ /created/
        end
      end
    end
  end

  describe "GET 'show'" do
    before(:each) do
      @diary = Factory(:diary)
      @entry = Factory(:entry, :diary => @diary)
    end

    describe "for non-existing diary" do
      it "should redirect to root page" do
        get :show, :diary_id => @diary.id+1, :id => @entry
        response.should redirect_to(root_path)
      end
    end

    describe "for non-existing entries" do
      it "should redirect to diary page" do
        get :show, :diary_id => @diary, :id => @entry.id+1
        response.response_code.should == 404
      end
    end

    it "should have the right title" do
      get :show, :diary_id => @diary, :id => @entry
      response.should have_selector("title", :content => @diary.title)
      response.should have_selector("title", :content => @entry.title)
    end

    it "should contain the right content" do
      get :show, :diary_id => @diary, :id => @entry
      response.should contain(@entry.content)
    end

    it "should have the link to the diary" do
      get :show, :diary_id => @diary, :id => @entry
      response.should have_selector("a",
                                    :href => diary_path(@diary),
                                    :content => "Back to diary")
    end
  end

  it "should have deletion" do
    pending "deletion"
  end

  describe "PUT 'update'" do
    before(:each) do
      @diary = Factory(:diary)
      @entry = Factory(:entry, :diary => @diary)
      @attr = {
        :title => "New title",
        :content => "New content is " + Faker::Lorem.sentence(20)
      }
    end

    it "should respond to update" do
      pending "to be written"
      put :update, :diary_id => @diary, :id => @entry, :entry => @attr
    end
  end
end
