require 'spec_helper'

describe OptRecord do
  it "should respond to :time" do
    OptRecord.new.should respond_to(:time)
  end

  it "should respond to :value" do
    OptRecord.new.should respond_to(:value)
  end

  it "should respond to :diary_id" do
    OptRecord.new.should respond_to(:diary_id)
  end

  describe "default_scope" do
    before(:each) do
      @diary = Factory(:diary)
      @col = Factory(:opt_column, :diary => @diary)
      @rec1 = Factory(:opt_record, :diary => @diary, :value => {@col.ckey => 1.0}, :time => Time.now - 5)
      @rec2 = Factory(:opt_record, :diary => @diary, :value => {@col.ckey => 1.0}, :time => Time.now - 10)
      @rec3 = Factory(:opt_record, :diary => @diary, :value => {@col.ckey => 1.0}, :time => Time.now)
    end

    it "should order records by :time in descending order" do
      @diary.opt_records.should == [@rec3, @rec1, @rec2]
    end
  end

  describe "accessibility" do
    it "should allow access to time" do
      t = Time.now
      OptRecord.new(:time => t).time.should == t
    end

    it "should allow access to value" do
      value = "hogehoge"
      OptRecord.new(:value => value).value.should == value
    end

    it "should not allow access to diary_id" do
      id = 123
      OptRecord.new(:diary_id => id).diary_id.should_not == id
    end
  end

  describe "diary association" do
    it "should respond to :diary" do
      OptRecord.new.should respond_to(:diary)
    end

    it "should have the right diary" do
      diary = Factory(:diary)
      rec = diary.opt_records.build
      rec.diary.should == diary
    end
  end

  describe "validation" do
    before(:each) do
      @diary = Factory(:diary)
      @column1 = @diary.opt_columns.create!(:name => "Test column 1",
                                            :col_type => OptColumn::COL_INTEGER)
      @column2 = @diary.opt_columns.create!(:name => "Test column 2",
                                            :col_type => OptColumn::COL_FLOAT)
      @attr = {
        :time => Time.at(0),
        :value => {@column1.ckey => 10, @column2.ckey => 1.0}
      }
    end

    it "should create an instance with valid value" do
      lambda do
        @diary.opt_records.create!(@attr)
      end.should change(OptRecord, :count).by(1)
    end

    it "should allow valid input" do
      @diary.opt_records.build(@attr).should be_valid
    end

    it "should require time" do
      @diary.opt_records.build(@attr.merge(:time => nil)).should_not be_valid
    end

    it "should require value" do
      @diary.opt_records.build(@attr.merge(:value => nil)).should_not be_valid
      @diary.opt_records.build(@attr.merge(:value => "")).should_not be_valid
    end

    it "should require Hash as :value attribute" do
      @diary.opt_records.build(@attr.merge(:value => 1)).should_not be_valid
      @diary.opt_records.build(@attr.merge(:value => "foo")).should_not be_valid
      @diary.opt_records.build(@attr.merge(:value => [1,2,3])).should_not be_valid
      @diary.opt_records.build(@attr.merge(:value => {})).should_not be_valid
    end

    it "should allow only existing column as hash keys of :value attribute" do
      @diary.opt_records.build(@attr.merge(:value => {:foo => "bar"})).should_not be_valid
    end

    it "should check types of each value in :value attribute" do
      @diary.opt_records.build(@attr.merge(:value => {@column1.ckey => "foo"})).should_not be_valid
    end
  end

  describe "value method" do
    before(:each) do
      @diary = Factory(:diary)
      @column1 = @diary.opt_columns.create!(:name => "Test column 1",
                                            :col_type => OptColumn::COL_INTEGER)
      @column2 = @diary.opt_columns.create!(:name => "Test column 2",
                                            :col_type => OptColumn::COL_FLOAT)
      @column3 = @diary.opt_columns.create!(:name => "Test column 3",
                                            :col_type => OptColumn::COL_STRING)
      @value = {
        @column1.ckey => 10,
        @column2.ckey => 1.0,
        @column3.ckey => "hello world"
      }
      @record = @diary.opt_records.create!(:time => Time.at(0),
                                           :value => @value)
      @record.reload
    end

    it "should respond to :value" do
      @record.should respond_to(:value)
    end

    it "should return empty Hash for empty OptRecord" do
      empty_record = @diary.opt_records.build
      empty_record.value.should == {}
    end

    it "should return the right value" do
      @record.value.should == @value
      @record.value[@column1.ckey].should == @value[@column1.ckey]
    end
  end

  describe "virtual method for dynamic OptColumn" do
    before(:each) do
      @diary = Factory(:diary)
      @entry = Factory(:entry, :diary => @diary)
      @col1 = Factory(:opt_column, :diary => @diary)
      @col2 = Factory(:opt_column, :name => "Fat", :diary => @diary)
      @col3 = Factory(:opt_column, :name => "body",
                      :diary => Factory(:diary, :title => "Yet Another Diary"))
      @record = @diary.opt_records.build
    end

    it "should respond to 'column key' methods" do
      [@col1, @col2].each do |col|
        @record.should respond_to(col.ckey)
      end
    end

    it "should return nil for unset columns" do
      @record.send(@col1.ckey).should be_nil
      @record.send(@col2.ckey).should be_nil
    end

    it "should raise NoMethodError for unknown column" do
      lambda do
        @record.send(@col3.ckey)
      end.should raise_error
    end

    it "should raise errors for other non-existing methods" do
      lambda do
        @record.hogehogepiyopiyo
      end.should raise_error
    end

    describe "for non-empty record" do
      before(:each) do
        @record = @diary.opt_records.build(:time => Time.now,
                                           :value => {
                                             @col1.ckey => 1.0,
                                             @col2.ckey => 2.0
                                           })
      end

      it "should return right values" do
        @record.send(@col1.ckey).should == 1.0
        @record.send(@col2.ckey).should == 2.0
      end

      it "should update :value attribute" do
        @record.send(@col1.ckey.to_s+"=", 3.0)
        @record.send(@col1.ckey).should == 3.0
        @record.value.should == { @col1.ckey => 3.0, @col2.ckey => 2.0 }
      end
    end
  end

  describe "'of' class method" do
    it "should respond to :of" do
      OptRecord.should respond_to(:of)
    end

    describe "with unsaved empty OptColumn" do
      before(:each) do
        @opt_column = OptColumn.new
      end

      it "should return emtpy Array" do
        OptRecord.of(@opt_column).should == []
      end
    end

    describe "with existing OptColumn" do
      before(:each) do
        @diary = Factory(:diary)
        @opt_column = Factory(:opt_column, :diary => @diary)
        @another_column = Factory(:opt_column, :diary => @diary,
                                  :name => Factory.next(:col_name))
        @opt_records = []
        3.times do |n|
          @opt_records << @diary.opt_records.create!(:time => Time.now - n,
                                                     :value => {
                                                       @opt_column.ckey => n.to_f,
                                                       @another_column.ckey => (-n).to_f
                                                     })
        end

        @other_records = []
        3.times do |n|
          @other_records << @diary.opt_records.create!(:time => Time.now + n,
                                                       :value => {
                                                         @another_column.ckey => (-n).to_f
                                                       })
        end
      end

      it "should return records of OptColumn" do
        OptRecord.of(@opt_column).should == @opt_records
      end
    end
  end
end
# == Schema Information
#
# Table name: opt_records
#
#  id         :integer         not null, primary key
#  value      :string(255)
#  diary_id   :integer
#  created_at :datetime
#  updated_at :datetime
#  time       :datetime
#

