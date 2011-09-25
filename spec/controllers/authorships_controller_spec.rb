require 'spec_helper'

describe AuthorshipsController do
  describe "POST 'create'" do
    before(:each) do
      @diary = Factory(:diary)
      @user = Factory(:user)
      @target_user = Factory(:user,
                             :name => Faker::Name.name,
                             :email => Factory.next(:email))
      @attr = {
        :diary_id => @diary.id,
        :user_id => @target_user.id
      }
    end

    it "should redirect to signin page" do
      post :create, :authorship => @attr
      response.should redirect_to(signin_path)
      @user.should_not be_author(@diary)
    end

    describe "for signed-in users" do
      before(:each) do
        test_sign_in(@user)
      end

      it "should not allow for non-authors to create new authorship" do
        lambda do
          post :create, :authorship => @attr
        end.should_not change(Authorship, :count)
      end

      it "should redirect to diary page" do
        post :create, :authorship => @attr
        response.should redirect_to(diary_path(@diary))
      end

      it "should show error flash message" do
        post :create, :authorship => @attr
        flash[:error].should_not be_empty
      end

      describe "for authors" do
        before(:each) do
          @user.participate(@diary)
        end

        it "should create a new authorship" do
          lambda do
            post :create, :authorship => @attr
          end.should change(Authorship, :count).by(1)
          @target_user.should be_author(@diary)
        end

        it "should redirect to diaries#edit" do
          post :create, :authorship => @attr
          response.should redirect_to(edit_diary_path(@diary))
        end

        it "should show successful flash message" do
          post :create, :authorship => @attr
          flash[:success].should_not be_empty
        end

        describe "failures" do
          it "should fail with invalid inputs" do
            lambda do
              post :create, :authorship => @attr.merge(:user_id => 9999)
            end.should_not change(Authorship, :count)

            lambda do
              post :create, :authorship => @attr.merge(:diary_id => 9999)
            end.should_not change(Authorship, :count)
          end

          it "should fail if target_user is already an author" do
            @target_user.participate(@diary)
            lambda do
              post :create, :authorship => @attr
            end.should_not change(Authorship, :count)
          end
        end
      end
    end
  end
end
