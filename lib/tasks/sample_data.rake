
namespace :db do
  desc "Fill database with sample data"
  task :populate => :environment do
    Rake::Task['db:reset'].invoke
    user = User.create!(:name			=> "Yuto HAYAMIZU",
                        :email			=> "info@hayamin.com",
                        :password		=> "hogehoge",
                        :password_confirmation	=> "hogehoge")
    diary = Diary.create!(:title => "Volvox diary",
                          :desc => "This is a sample diary")
    col1 = diary.opt_columns.create!(:name => "Weight [g]", :col_type => OptColumn::COL_FLOAT)
    col2 = diary.opt_columns.create!(:name => "Running Distance [km]", :col_type => OptColumn::COL_FLOAT)
    user.participate(diary)
    61.times do |n|
      diary.entries.create!(:date => Date.today - n,
                            :memo => Faker::Lorem.paragraphs(5).join("\n\n"))
      diary.opt_records.create!(:time => Time.now,
                                :value => {
                                  col1.ckey => 100.0 + rand * 100,
                                  col2.ckey => 10.0 * rand
                                })
    end
  end
end
