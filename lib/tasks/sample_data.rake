
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
    diary.opt_columns.create!(:name => "Weight", :col_type => OptColumn::COL_FLOAT)
    diary.opt_columns.create!(:name => "Running Distance", :col_type => OptColumn::COL_FLOAT)
    user.participate(diary)
    61.times do |n|
      diary.entries.create!(:date => Date.today - n,
                            :memo => Faker::Lorem.paragraphs(5).join("\n\n"))
    end
  end
end
