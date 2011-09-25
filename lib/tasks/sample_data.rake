
namespace :db do
  desc "Fill database with sample data"
  task :populate => :environment do
    Rake::Task['db:reset'].invoke
    user = User.create!(:name			=> "Yuto HAYAMIZU",
                        :email			=> "info@hayamin.com",
                        :password		=> "hogehoge",
                        :password_confirmation	=> "hogehoge")
    User.create!(:name => Faker::Name.name,
                 :email => Faker::Internet.email,
                 :password => "foobar",
                 :password_confirmation => "foobar")
    diary = Diary.create!(:title => "Volvox diary",
                          :desc => "This is a sample diary")
    col1 = diary.opt_columns.create!(:name => "Weight [g]", :col_type => OptColumn::COL_FLOAT)
    col2 = diary.opt_columns.create!(:name => "Running Distance [km]", :col_type => OptColumn::COL_FLOAT)
    user.participate(diary)
    61.times do |n|
      diary.entries.create!(:date => Date.today - n,
                            :memo => Faker::Lorem.paragraphs(5).join("\n\n"))
      time = n.days.ago + (rand - 0.5) * 24 * 3600
      weight = 200 - n + (rand - 0.5) * 10
      diary.opt_records.create!(:time => time,
                                :value => {
                                  col1.ckey => weight,
                                  col2.ckey => 10.0 * rand
                                })
    end
  end
end
