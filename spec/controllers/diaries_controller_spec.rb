require 'spec_helper'

describe DiariesController do
  render_views

  after(:each) do
    response.should_not contain("translation missing")
  end

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
        response.should have_selector("title", :content => t('diaries.new.title'))
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
        response.should have_selector("title", :content => t('diaries.edit.title'))
      end

      it "should have form fields" do
        get :edit, :id => @diary
        response.should have_selector("input[type='text'][name='diary[title]']")
        response.should have_selector("input[type='text'][name='diary[desc]']")
      end

      it "should have a author list" do
        get :edit, :id => @diary
        @diary.authors.each do |author|
          response.should have_selector("li.author", :content => author.name)
          response.should have_selector("a", :href => user_path(author))
        end
      end

      describe "with many authors" do
        before(:each) do
          @authors = [@user]
          5.times do
            user = Factory(:user,
                           :name => Faker::Name.name,
                           :email => Factory.next(:email))
            user.participate(@diary)
            @authors << user
          end
        end

        it "should have the right author list" do
          get :edit, :id => @diary
          @diary.authors.each do |author|
            response.should have_selector("section.main li.author", :content => author.name)
            response.should have_selector("a", :href => user_path(author))
          end
        end
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

    describe "for signed-in users" do
      before(:each) do
        @user = test_sign_in(Factory(:user))
      end

      it "should not have the link to new entry page" do
        get :show, :id => @diary
        response.should_not have_selector("a", :href => new_diary_entry_path(@diary))
      end

      it "should not have the link to the edit page" do
        get :show, :id => @diary
        response.should_not have_selector("a", :href => edit_diary_path(@diary))
      end

      it "should not have a form for adding new OptRecord" do
        get :show, :id => @diary
        response.should_not have_selector("form",
                                          :action => diary_opt_records_path(@diary))
      end

      describe "for authors" do
        before(:each) do
          @user.participate(@diary)
        end

        it "should have the link to new entry page" do
          get :show, :id => @diary
          response.should have_selector("a",
                                        :href => new_diary_entry_path(@diary),
                                        :content => t('diaries.show.new_entry'))
        end

        it "should have the link to the edit page" do
          get :show, :id => @diary
          response.should have_selector("a",
                                        :href => edit_diary_path(@diary),
                                        :content => t('diaries.show.edit'))
        end

        it "should not have a form for adding new OptRecord" do
          get :show, :id => @diary
          response.should_not have_selector("form",
                                            :action => diary_opt_records_path(@diary))
        end

        describe "with some OptColumns" do
          before(:each) do
            @col1 = Factory(:opt_column, :diary => @diary)
            @col2 = Factory(:opt_column, :diary => @diary,
                            :name => Factory.next(:col_name))
            @col3 = Factory(:opt_column, :diary => @diary,
                            :name => Factory.next(:col_name))
          end

          it "should have a form for adding new OptRecord" do
            get :show, :id => @diary
            response.should have_selector("form",
                                          :action => diary_opt_records_path(@diary))
            response.should have_selector("input[name='opt_record[time]'][value='#{Time.now.strftime("%Y-%m-%dT%H:%M")}']")
            @diary.opt_columns.all.each do |col|
              response.should have_selector("input[name='opt_record[#{col.ckey}]']")
            end
          end

          it "should have links for each OptColumn name" do
            get :show, :id => @diary
            @diary.opt_columns.all.each do |col|
              response.should have_selector("a",
                                            :href => diary_opt_column_path(@diary, col))
            end
          end

          describe "with some records" do
            before(:each) do
              @records = []
              @records << @diary.opt_records.create!(:time => Time.now,
                                                     :value => {
                                                       @col1.ckey => 1.0,
                                                       @col2.ckey => 1.0,
                                                     })
              @records << @diary.opt_records.create!(:time => Time.now,
                                                     :value => {
                                                       @col1.ckey => 1.0,
                                                     })
            end


            it "should show # of records" do
              get :show, :id => @diary
              response_xpath('//table/tr[3]/td[2]').size.should == 1
              response_xpath('//table/tr[3]/td[2]').first.inner_text.should include("2 records")

              response_xpath('//table/tr[3]/td[3]').size.should == 1
              response_xpath('//table/tr[3]/td[3]').first.inner_text.should include("1 record")

              response_xpath('//table/tr[3]/td[4]').size.should == 1
              response_xpath('//table/tr[3]/td[4]').first.inner_text.should include("0 record")
            end
          end
        end
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
                          :date => Factory.next(:date),
                          :memo => Faker::Lorem.sentence(50))
          @entries.push(entry)
        end
      end

      it "should have entries displayed" do
        get :show, :id => @diary
        @entries.each do |entry|
          entry.memo.should_not be_nil
          response.should have_selector("h2", :content => entry.date.to_s)
          response.body.should contain(entry.memo)
        end
      end

      it "should display the right number of entries" do
        get :show, :id => @diary
        response_xpath("//article").size.should == 5
      end

      it "should have links to entries" do
        get :show, :id => @diary
        @entries.each do |entry|
          response.should have_selector("a",
                                        :href => diary_entry_path(@diary, entry),
                                        :content => entry.date.to_s)
          # response.should have_selector("section", :content => entry.content)
        end
      end

      it "should not have pagination links" do
        get :show, :id => @diary
        response.should_not have_selector("a",
                                          :href => diary_path(:page => 2),
                                          :content => "Next")
      end

      describe "for authors" do
        before(:each) do
          @user = test_sign_in(Factory(:user))
          @user.participate(@diary)
        end

        it "should have links to edit pages of entries" do
          get :show, :id => @diary
          @entries.each do |entry|
            response.should have_selector("a",
                                          :href => edit_diary_entry_path(@diary,
                                                                         entry),
                                          :content => t('entries.entry.edit'))
            # response.should have_selector("section", :content => entry.content)
          end
        end
      end
    end

    describe "with many entries" do
      before(:each) do
        @entries = Array.new
        31.times do |n|
          entry = Factory(:entry,
                          :diary => @diary,
                          :date => Factory.next(:date),
                          :memo => Faker::Lorem.sentence(50))
          @entries.push(entry)
        end
      end

      it "should have pagination links" do
        get :show, :id => @diary
        response.should have_selector("a",
                                      :href => diary_path(:page => 2),
                                      :content => t('will_paginate.next_label'))
        response.should have_selector("a",
                                      :href => diary_path(:page => 2),
                                      :content => "2")
        response_xpath("//article").size.should == 30
      end
    end
  end

  describe "opt_columns editor on edit page" do
    before(:each) do
      @user = test_sign_in(Factory(:user))
      @diary = Factory(:diary)
      @user.participate(@diary)
    end

    it "should have form to add new OptColumns" do
      get :edit, :id => @diary
      response.should have_selector("form[action='#{diary_opt_columns_path(@diary)}']")
      response.should have_selector("input[type='text'][name='opt_column[name]']")
      response.should have_selector("select[name='opt_column[col_type]']")
      response.should have_selector("form[action='#{diary_opt_columns_path(@diary)}'] input[type='submit']")
    end

    describe "diary with some opt_columns" do
      before(:each) do
        @columns = []
        (1..5).each do |n|
          @diary.opt_columns.create!(:name => "Column no.#{n}",
                                     :col_type => OptColumn::COL_INTEGER)
        end
      end

      it "should list existing columns in edit page" do
        get :edit, :id => @diary
        @columns.each do |col|
          response.should contain(col.name)
        end
      end
    end
  end

  it "should have deletion" do
    pending "deletion"
  end

  it "should have UI for user participation" do
    pending "consider UI"
  end
end
