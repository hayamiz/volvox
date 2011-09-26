require 'spec_helper'

describe OptColumn do
  describe "types of column" do
    it "should have add_col_type method" do
      OptColumn.should respond_to(:add_col_type)
    end

    it "should add a column type" do
      OptColumn.constants.should_not include(:COL_HOGE)
      OptColumn.add_col_type(:COL_HOGE, 1)
      OptColumn.constants.should include(:COL_HOGE)
      OptColumn.instance_eval("remove_const(:COL_HOGE); @col_types.pop")
    end

    it "should have col_types" do
      OptColumn.should respond_to(:col_types)
    end

    it "should list all column types by col_types method" do
      OptColumn.col_types.should == [[:COL_INTEGER, 1],
                                     [:COL_FLOAT, 2],
                                     [:COL_STRING, 3]]
    end

    describe "with int, float, and string" do
      it "should include COL_INTEGER" do
        OptColumn.constants.should include(:COL_INTEGER)
      end

      it "should include COL_FLOAT" do
        OptColumn.constants.should include(:COL_FLOAT)
      end

      it "should include COL_STRING" do
        OptColumn.constants.should include(:COL_STRING)
      end

      describe "management of column types" do
        describe "col_name class method" do
          it "should respond to :col_type_name" do
            OptColumn.should respond_to(:col_type_name)
          end

          it "should return column name" do
            OptColumn.col_type_name(OptColumn::COL_INTEGER).should == t("opt_column.types.integer")
            OptColumn.col_type_name(OptColumn::COL_FLOAT).should == t("opt_column.types.float")
            OptColumn.col_type_name(OptColumn::COL_STRING).should == t("opt_column.types.string")
          end

          it "should return nil for unknown types" do
            OptColumn.col_type_name(0).should be_nil
            OptColumn.col_type_name(100).should be_nil
          end
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
        col = OptColumn.new(:col_type => OptColumn::COL_STRING)
        col[:col_type].should == OptColumn::COL_STRING
      end

      it "should deny :diary_id" do
        col = OptColumn.new(:diary_id => 123456)
        col[:diary_id].should_not == 123456
      end
    end
  end

  describe "ckey method" do
    before(:each) do
      @diary = Factory(:diary)
      @col = Factory(:opt_column, :diary => @diary)
    end

    it "should respond to ckey" do
      @col.should respond_to(:ckey)
    end

    it "should return symbol to be used as attribute key in OptRecord#value" do
      @col.ckey.should == "c#{@col.id}".to_sym
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

      it "should require col_type" do
        col = @diary.opt_columns.build(:name => "hoge")
        col.should_not be_valid
      end

      it "should not accept unknown types" do
        col = @diary.opt_columns.build(:name => "hoge",
                                       :col_type => 0)
        col.should_not be_valid
        col = @diary.opt_columns.build(:name => "hoge",
                                       :col_type => 4)
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

      it "should accept COL_STRING" do
        col = @diary.opt_columns.build(@attr.merge(:col_type => OptColumn::COL_STRING))
        col.should be_valid
      end
    end
  end

  describe "'unit' method" do
    before(:each) do
      @opt_column = OptColumn.new(:name => "Test column",
                                  :col_type => OptColumn::COL_FLOAT)
    end

    it "should respond to :unit" do
      @opt_column.should respond_to(:unit)
    end

    it "should return nil for column without unit description in :name attribute" do
      @opt_column.unit.should == nil
    end

    it "should recognize unit description in :name" do
      @opt_column.name = "Test column [original unit]"
      @opt_column.unit.should == "original unit"
    end
  end
end
# == Schema Information
#
# Table name: opt_columns
#
#  id         :integer         not null, primary key
#  diary_id   :integer
#  name       :string(255)
#  col_type   :integer
#  created_at :datetime
#  updated_at :datetime
#

