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
end
