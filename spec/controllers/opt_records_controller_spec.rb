require 'spec_helper'

describe OptRecordsController do
  render_views

  describe "create method" do
    before(:each) do
      @user = Factory(:user)
      @diary = Factory(:diary)
      @column = Factory(:opt_column, :diary => @diary)
      @attr = {
        :time => Time.at(0),
        :value => Marshal.dump("c#{@column.id}".to_sym => 10)
      }
    end

    describe "for non-signed-in users" do
      it "should redirect to sign in page" do
        post :create, :diary_id => @diary, :opt_record => @attr
        response.should redirect_to(signin_path)
      end
    end
  end
end
