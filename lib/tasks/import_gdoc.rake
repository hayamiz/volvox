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
    user.participate(diary)
    puts "** importing #{ENV['FILE']}"
    rows = CSV::read(ENV['FILE'])
    rows.shift
    rows.each do |row|
      puts row[0]
      next if row[4].nil?
      diary.entries.create!(:date => Date.parse(row[0]),
                            :memo => row[4].toutf8)
    end
  end
end
