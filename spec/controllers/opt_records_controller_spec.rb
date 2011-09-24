require 'spec_helper'

describe OptRecordsController do
  render_views

  describe "index method" do
    before(:each) do
      @user = Factory(:user)
      @diary = Factory(:diary)
      @cols = []
      3.times do
        @cols << Factory(:opt_column,
                         :diary => @diary,
                         :name => Factory.next(:col_name))
      end
      @records = []
      10.times do
        value = {}
        @cols.each do |col|
          value[col.ckey] = rand
        end
        @records << Factory(:opt_record,
                            :diary => @diary,
                            :value => value)
      end
    end

    it "should show table" do
      get :index, :diary_id => @diary
      response_xpath("//table/tr/th").size.should == @cols.size + 1 # time + col names
      response_xpath("//table/tr/td").size.should == (@cols.size + 1) * @records.size
    end
  end

  describe "create method" do
    before(:each) do
      @user = Factory(:user)
      @diary = Factory(:diary)
      @column = Factory(:opt_column, :diary => @diary)
      @attr = {
        :time => Time.at(0),
        @column.ckey => 10
      }
    end

    describe "for non-signed-in users" do
      it "should redirect to sign in page" do
        post :create, :diary_id => @diary, :opt_record => @attr
        response.should redirect_to(signin_path)
      end
    end

    describe "for signed-in users" do
      before(:each) do
        test_sign_in(@user)
      end

      it "should redirect to diary page" do
        post :create, :diary_id => @diary, :opt_record => @attr
        response.should redirect_to(diary_path(@diary))
      end

      it "should not create an instance" do
        lambda do
          post :create, :diary_id => @diary, :opt_record => @attr
        end.should_not change(OptRecord, :count)
      end

      it "should show error flash message" do
        post :create, :diary_id => @diary, :opt_record => @attr
        flash[:error].should_not be_empty
      end

      describe "for authors" do
        before(:each) do
          @user.participate(@diary)
        end

        it "should create an instance" do
          lambda do
            post :create, :diary_id => @diary, :opt_record => @attr
          end.should change(OptRecord, :count).by(1)
        end

        it "should show successful flash message" do
          post :create, :diary_id => @diary, :opt_record => @attr
          flash[:success].should_not be_nil
          flash[:success].should_not be_empty
        end

        describe "with some columns" do
          before(:each) do
            @col1 = @column
            @col2 = Factory(:opt_column, :diary => @diary, :name => Factory.next(:col_name))
            @attr = {
              :time => Time.at(0),
              @col1.ckey => 10,
              @col2.ckey => ""
            }
          end

          it "should create an instance" do
            lambda do
              post :create, :diary_id => @diary, :opt_record => @attr
            end.should change(OptRecord, :count).by(1)
          end

          it "should create an instance with nil for col2" do
            post :create, :diary_id => @diary, :opt_record => @attr
            opt_record = assigns(:opt_record)
            opt_record.send(@col2.ckey).should be_nil
          end
        end
      end
    end
  end
end
