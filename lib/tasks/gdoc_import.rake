# -*- coding: utf-8 -*-

require 'kconv'
require 'csv'

namespace :db do
  desc "Import data from csv file exported from GDoc"
  task :gdoc_import => [:migrate] do
    raise ArgumentError.new("set FILE as /path/to/gdoc.csv") unless ENV['FILE']
    user = User.find_by_email("info@hayamin.com")
    if user
      puts "== User found: #{user.name} =="
    else
      raise StandardError.new("User not found")
    end

    diary = Diary.find_by_title("ボルちゃん日記")
    if diary
      puts "== Diary found =="
    else
      puts "== Diary not found. Creating a diary =="
      diary = Diary.create!(:title => "ボルちゃん日記",
                            :desc => "ボルちゃん(8/28誕生日, ♀)の健康状態等を記録する日記。")
    end
    weight_col = diary.opt_columns.find_by_name("体重[g]")
    unless weight_col
      weight_col = diary.opt_columns.create!(:name => "体重[g]",
                                             :col_type => OptColumn::COL_FLOAT)
    end
    running_col = diary.opt_columns.find_by_name("回し車積算距離[km]")
    unless running_col
      running_col = diary.opt_columns.create!(:name => "回し車積算距離[km]",
                                              :col_type => OptColumn::COL_FLOAT)
    end

    user.participate(diary)
    puts "== Cleaning up the diary: #{diary.title} =="

    puts "== Importing #{ENV['FILE']} =="
    rows = CSV::read(ENV['FILE'])
    rows.shift
    rows.each do |row|
      next if row[4].nil?
      date = Date.parse(row[0])
      entry = diary.entries.find_by_date(date)
      unless entry
        entry = diary.entries.build(:date => date)
      end
      entry.memo = row[4].toutf8
      entry.save!
      puts "saved entry #{row[0]}"

      rec_data = {}
      rec_data[weight_col.ckey] = row[1].to_f unless row[1].nil?
      rec_data[running_col.ckey] = row[2].to_f unless row[2].nil?
      if ! rec_data.empty?
        record = diary.opt_records.find_by_time(date.to_time)
        unless record
          record = diary.opt_records.build(:time => date.to_time)
        end
        record.value = rec_data
        record.save!
      end
    end
  end
end
