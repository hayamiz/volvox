# -*- coding: utf-8 -*-

require 'kconv'
require 'csv'

namespace :db do
  desc "Import data from csv file exported from GDoc"
  task :gdoc_import => [:populate] do
    raise ArgumentError.new("set FILE as /path/to/gdoc.csv") unless ENV['FILE']
    user = User.find_by_email("info@hayamin.com")
    diary = Diary.create!(:title => "ボルちゃん日記",
                          :desc => "ボルちゃん(8/28誕生日, ♀)の健康状態等を記録する日記。")
    weight_col = diary.opt_columns.create!(:name => "体重[g]",
                                           :col_type => OptColumn::COL_FLOAT)
    running_col = diary.opt_columns.create!(:name => "回し車積算距離[km]",
                                            :col_type => OptColumn::COL_FLOAT)
    user.participate(diary)
    puts "** importing #{ENV['FILE']}"
    rows = CSV::read(ENV['FILE'])
    rows.shift
    rows.each do |row|
      next if row[4].nil?
      date = Date.parse(row[0])
      diary.entries.create!(:date => date,
                            :memo => row[4].toutf8)
      puts "created entry #{row[0]}"

      rec_data = {}
      rec_data[weight_col.ckey] = row[1].to_f unless row[1].nil?
      rec_data[running_col.ckey] = row[2].to_f unless row[2].nil?
      if ! rec_data.empty?
        diary.opt_records.create!(:time => date.to_time,
                                  :value => rec_data)
      end
    end
  end
end
