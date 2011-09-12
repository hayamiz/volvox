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
        response.should have_selector("input[type='text'][name='entry[temperature]']")
        response.should have_selector("input[type='text'][name='entry[humidity]']")
        response.should have_selector("textarea[name='entry[action_feed]']")
        response.should have_selector("textarea[name='entry[action_care]']")
        response.should have_selector("textarea[name='entry[pet_feces]']")
        response.should have_selector("textarea[name='entry[pet_physical]']")
        response.should have_selector("textarea[name='entry[memo]']")
        response.should have_selector("select[name='entry[date(1i)]']")
        response.should have_selector("select[name='entry[date(2i)]']")
        response.should have_selector("select[name='entry[date(3i)]']")
      end

      it "should not have form fields for obsolete attributes" do
        get :new, :diary_id => @diary
        response.should_not have_selector("input[type='text'][name='entry[title]']")
        response.should_not have_selector("textarea[name='entry[content]']")
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
        get :new, :diary_id => @diary
        response.should have_selector("input[type='text'][name='entry[temperature]']")
        response.should have_selector("input[type='text'][name='entry[humidity]']")
        response.should have_selector("textarea[name='entry[action_feed]']")
        response.should have_selector("textarea[name='entry[action_care]']")
        response.should have_selector("textarea[name='entry[pet_feces]']")
        response.should have_selector("textarea[name='entry[pet_physical]']")
        response.should have_selector("textarea[name='entry[memo]']")
        response.should have_selector("select[name='entry[date(1i)]']")
        response.should have_selector("select[name='entry[date(2i)]']")
        response.should have_selector("select[name='entry[date(3i)]']")
      end

      it "should not have form fields for obsolete attributes" do
        get :new, :diary_id => @diary
        response.should_not have_selector("input[type='text'][name='entry[title]']")
        response.should_not have_selector("textarea[name='entry[content]']")
      end
    end
  end

  describe "POST 'create'" do
    before(:each) do
      @diary = Factory(:diary)
      @attr = {
        "date(1i)" => "2011",
        "date(2i)" => "9",
        "date(3i)" => "12",
        :memo => "This is a test.",
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

        it "should not raise an error with empty date" do
          lambda do
            attr = @attr.merge("date(1i)" => nil,
                               "date(2i)" => "9",
                               "date(3i)" => "12")
            post :create, :diary_id => @diary, :entry => attr
          end.should_not raise_error

          lambda do
            attr = @attr.merge("date(1i)" => nil,
                               "date(2i)" => nil,
                               "date(3i)" => nil)
            post :create, :diary_id => @diary, :entry => attr
          end.should_not raise_error
        end

        it "should not raise an error with invalid date" do
          lambda do
            attr = @attr.merge("date(1i)" => "hoge",
                               "date(2i)" => "9",
                               "date(3i)" => "12")
            post :create, :diary_id => @diary, :entry => attr
          end.should_not raise_error(StandardError)
        end

        it "should reject empty date" do
          lambda do
            attr = @attr.merge("date(1i)" => nil,
                               "date(2i)" => nil,
                               "date(3i)" => nil)
            post :create, :diary_id => @diary, :entry => attr
          end.should_not change(Entry, :count)
        end

        it "should render new page with invalid inputs" do
          attr = @attr.merge("date(1i)" => nil,
                             "date(2i)" => nil,
                             "date(3i)" => nil)
          post :create, :diary_id => @diary, :entry => attr
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
      response.should have_selector("title", :content => @entry.date.to_s)
    end

    it "should contain the right content" do
      get :show, :diary_id => @diary, :id => @entry
      response.body.should include(BlueCloth.new(@entry.action_feed).to_html)
      response.body.should include(BlueCloth.new(@entry.action_care).to_html)
      response.body.should include(BlueCloth.new(@entry.pet_feces).to_html)
      response.body.should include(BlueCloth.new(@entry.pet_physical).to_html)
      response.body.should include(BlueCloth.new(@entry.memo).to_html)

      pending ""
      response.should contain(@entry.temperature)
      response.should contain(@entry.humidity)
    end

    it "should show availability of attributes" do
      entry = Factory(:empty_entry, :diary => @diary, :date => Factory.next(:date))
      get :show, :diary_id => @diary, :id => entry
      response.should have_selector("section.entry-body", :content => "N/A")
    end

    it "should sanitized malicious contents" do
      text = Faker::Lorem.sentence(20)
      entry = Factory(:entry,
                      :diary => @diary,
                      :date => Factory.next(:date),
                      :memo => text + "<script>alert('hello world')</script>")
      get :show, :diary_id => @diary, :id => entry
      response.body.should_not include("<script>alert('hello world')</script>")
      response.body.should contain(text)
    end

    it "should have the link to the diary" do
      get :show, :diary_id => @diary, :id => @entry
      response.should have_selector("a",
                                    :href => diary_path(@diary),
                                    :content => "Back to diary")
    end

    describe "for non-authors" do
      it "should not show Edit link for singed-in non-auther users" do
        @user = test_sign_in(Factory(:user))
        get :show, :diary_id => @diary, :id => @entry
        response.should_not have_selector("a",
                                          :href => edit_diary_entry_path(@diary, @entry),
                                          :content => "Edit")
      end

      it "should not show Edit link for non-singed-in users" do
        get :show, :diary_id => @diary, :id => @entry
        response.should_not have_selector("a",
                                          :href => edit_diary_entry_path(@diary, @entry),
                                          :content => "Edit")
      end
    end

    describe "for authors" do
      before(:each) do
        @user = test_sign_in(Factory(:user))
        @user.participate(@diary)
      end

      it "should see Edit link" do
        get :show, :diary_id => @diary, :id => @entry
        response.should have_selector("a",
                                      :href => edit_diary_entry_path(@diary, @entry),
                                      :content => "Edit")
      end
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
        "date(1i)" => "2012",
        "date(2i)" => "10",
        "date(3i)" => "13",
        :memo => "This is a PUT test.",
      }
    end

    describe "for non-signed-in users" do
      it "should redirect to signin page" do
        put :update, :diary_id => @diary, :id => @entry, :entry => @attr
        response.should redirect_to(signin_path)
      end
    end

    describe "for non-author users" do
      before(:each) do
        @user = test_sign_in(Factory(:user))
      end

      it "should redirect to the diary page" do
        put :update, :diary_id => @diary, :id => @entry, :entry => @attr
        response.should redirect_to(diary_path(@diary))
      end

      it "should have error flash message" do
        put :update, :diary_id => @diary, :id => @entry, :entry => @attr
        flash[:error].should =~ /not an author/i
      end
    end

    describe "for authors" do
      before(:each) do
        @user = test_sign_in(Factory(:user))
        @user.participate(@diary)
      end

      describe "success" do
        it "should succeed" do
          put :update, :diary_id => @diary, :id => @entry, :entry => @attr
          @entry.reload
          @entry.date.year.should == 2012
          @entry.date.month.should == 10
          @entry.date.day.should == 13
          @entry.memo.should == @attr[:memo]
        end
        
        it "should should redirect to the entry page on success" do
          put :update, :diary_id => @diary, :id => @entry, :entry => @attr
          response.should redirect_to(diary_entry_path(@diary, @entry))
        end
        
        it "should should have flash message" do
          put :update, :diary_id => @diary, :id => @entry, :entry => @attr
          flash[:success] =~ /entry updated/
        end
      end
      
      describe "failure" do
        before(:each) do
          @attr = @attr.merge("date(1i)" => nil)
        end
        
        it "should fail with invalid data" do
          put :update, :diary_id => @diary, :id => @entry, :entry => @attr
          @entry.reload
          @entry.date.year.should_not == 2012
          @entry.date.month.should_not == 10
          @entry.date.day.should_not == 13
          @entry.memo.should_not == @attr[:memo]
        end
        
        it "should render edit page" do
          put :update, :diary_id => @diary, :id => @entry, :entry => @attr
          response.should render_template("entries/edit")
          response.should have_selector("input[type='text'][name='entry[temperature]']")
        end

        it "should have error messages" do
          pending ""
          put :update, :diary_id => @diary, :id => @entry, :entry => @attr
          response.should have_selector("div#error_explanation")
        end
      end
    end
  end
end
