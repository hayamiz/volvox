require 'spec_helper'

describe OptColumnsController do
  render_views

  describe "create" do
    before(:each) do
      @user = Factory(:user)
      @diary = Factory(:diary)
      @attr = {
        :name => "Test column",
        :col_type => OptColumn::COL_INTEGER
      }
    end

    describe "for non-signed-in users" do
      it "should redirect to sign in page" do
        post :create, :diary_id => @diary, :opt_column => @attr
        response.should redirect_to(signin_path)
      end
    end

    describe "for signed-in users" do
      before(:each) do
        test_sign_in(@user)
      end

      it "should reject non-author users" do
        lambda do
          post :create, :diary_id => @diary, :opt_column => @attr
        end.should_not change(OptColumn, :count)
      end

      it "should redirect to diary page" do
        post :create, :diary_id => @diary, :opt_column => @attr
        response.should redirect_to(diary_path(@diary))
      end

      describe "for authors" do
        before(:each) do
          @user.participate(@diary)
        end

        it "should create an instance" do
          lambda do
            post :create, :diary_id => @diary, :opt_column => @attr
          end.should change(OptColumn, :count).by(1)
        end

        it "should redirect to diary_edit page" do
          post :create, :diary_id => @diary, :opt_column => @attr
          response.should redirect_to(edit_diary_path(@diary))
        end

        it "should have flash message" do
          post :create, :diary_id => @diary, :opt_column => @attr
          flash[:success].should =~ /successfully created/
        end

        it "should reject invalid inputs" do
          lambda do
            post :create, :diary_id => @diary, :opt_column => { :name => "aaa" }
          end.should_not change(OptColumn, :count)
        end

        it "should redirect to edit diary page with invalid input" do
          post :create, :diary_id => @diary, :opt_column => {}
          response.should redirect_to(edit_diary_path(@diary))
          flash[:error].should =~ /failed to create a new column/
        end
      end
    end
  end

  describe "GET 'show'" do
    before(:each) do
      @user = Factory(:user)
      @diary = Factory(:diary)
      @user.participate(@diary)

      @col_float = @diary.opt_columns.create!(:name => "Weight[g]",
                                              :col_type => OptColumn::COL_FLOAT)
      @col_string = @diary.opt_columns.create!(:name => "Memo",
                                               :col_type => OptColumn::COL_STRING)
    end

    it "should return 404 for non-existing column id" do
      get :show, :diary_id => @diary, :id => 9999
      response.response_code.should == 404
    end

    describe "with float data" do
      before(:each) do
        @float_records = []
        30.times do |n|
          record = @diary.opt_records.create!(:time => (n.days.ago + 24 * 3600 * (rand - 0.5)),
                                              :value => { @col_float.ckey => 100 + rand * 100 })
          @float_records.push(record)
        end
        @float_records = @float_records.sort_by{|rec| rec.time }
      end

      it "should have a div for a chart" do
        get :show, :diary_id => @diary, :id => @col_float
        response.should have_selector("div#chart-#{@col_float.ckey}")
      end

      it "should have a table listing values for target column" do
        get :show, :diary_id => @diary, :id => @col_float
        response_xpath("//table/tr/td[2]").size.should > 0
        response_xpath("//table/tr/td[2]").each_with_index do |td_tag, idx|
          td_tag.inner_text.to_f.should == @float_records[idx].value[@col_float.ckey]
        end
      end

      it "should respond text/javascript to :format => :js" do
        get :show, :diary_id => @diary, :id => @col_float, :format => :js
        response.content_type.should == "text/javascript"
      end

      it "should render valid javascript for :format => :js" do
        get :show, :diary_id => @diary, :id => @col_float, :format => :js
        body = response.body
        @float_records.each do |rec|
          record_line = body.lines.select do |line|
            line =~ /\/\* record #{rec.id} \*\// # extract record by annotated comment
          end.first
          record_line.should_not be_nil
          record_line.should =~ /value:.*#{Regexp.quote(sprintf("%.2f", rec.value[@col_float.ckey]))}/
        end
      end
    end
  end
end
