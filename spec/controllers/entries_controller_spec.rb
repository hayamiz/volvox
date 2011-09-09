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

  it "should have deletion" do
    pending "deletion"
  end
end
