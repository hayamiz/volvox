require 'spec_helper'

describe OptColumn do
  describe "types of column" do
    it "should include INTEGER" do
      OptColumn.constants.should include(:COL_INTEGER)
    end

    it "should include FLOAT" do
      OptColumn.constants.should include(:COL_FLOAT)
    end

    describe "management of column types" do
      describe "col_name class method" do
        it "should respond to :col_type_name" do
          OptColumn.should respond_to(:col_type_name)
        end

        it "should return column name" do
          OptColumn.col_type_name(OptColumn::COL_INTEGER).should == "COL_INTEGER"
          OptColumn.col_type_name(OptColumn::COL_FLOAT).should == "COL_FLOAT"
        end

        it "should return nil for unknown types" do
          OptColumn.col_type_name(0).should be_nil
          OptColumn.col_type_name(100).should be_nil
        end
      end
    end
  end

  describe "attributes" do
    before(:each) do
      @col = OptColumn.new
    end

    [:name, :col_type, :diary_id].each do |attr|
      it("should respond to #{attr}"){ @col.should respond_to(attr) }
    end

    describe "accessibility" do
      it "should allow :name" do
        col = OptColumn.new(:name => "Test column")
        col[:name].should == "Test column"
      end

      it "should allow :col_type" do
        col = OptColumn.new(:col_type => OptColumn::COL_INTEGER)
        col[:col_type].should == OptColumn::COL_INTEGER
        col = OptColumn.new(:col_type => OptColumn::COL_FLOAT)
        col[:col_type].should == OptColumn::COL_FLOAT
      end

      it "should deny :diary_id" do
        col = OptColumn.new(:diary_id => 123456)
        col[:diary_id].should_not == 123456
      end
    end
  end

  describe "diary association" do
    before(:each) do
      @user = Factory(:user)
      @diary = Factory(:diary)
      @user.participate(@diary)
    end

    it "should respond to diary" do
      col = @diary.opt_columns.build
      col.should respond_to(:diary)
    end

    it "should be a Diary" do
      col = @diary.opt_columns.build
      col.diary.is_a?(Diary).should be_true
    end
  end

  describe "validations" do
    before(:each) do
      @user = Factory(:user)
      @diary = Factory(:diary)
      @user.participate(@diary)
      @attr = {
        :name => "Test column",
        :col_type => OptColumn::COL_INTEGER
      }
    end

    describe "invalid data" do
      it "should not accept an empty name" do
        col = @diary.opt_columns.build(:name => "",
                                       :col_type => OptColumn::COL_INTEGER)
        col.should_not be_valid
      end

      it "should not accept unknown types" do
        col = @diary.opt_columns.build(:name => "hoge",
                                       :col_type => 0)
        col.should_not be_valid
        col = @diary.opt_columns.build(:name => "hoge",
                                       :col_type => 3)
        col.should_not be_valid
        col = @diary.opt_columns.build(:name => "hoge",
                                       :col_type => 100)
        col.should_not be_valid
      end
    end

    describe "valida data" do
      it "should create an instance" do
        @diary.opt_columns.build(@attr).should be_valid
        lambda do
          @diary.opt_columns.create!(@attr)
        end.should change(OptColumn, :count).by(1)
      end

      it "should accept COL_INTEGER" do
        col = @diary.opt_columns.build(@attr.merge(:col_type => OptColumn::COL_INTEGER))
        col.should be_valid
      end

      it "should accept COL_FLOAT" do
        col = @diary.opt_columns.build(@attr.merge(:col_type => OptColumn::COL_FLOAT))
        col.should be_valid
      end
    end
  end
end
