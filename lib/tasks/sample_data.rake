
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
    user.participate(diary)
    diary.entries.create!(:title => "The first entry",
                         :content => Faker::Lorem.sentence(100))
    diary.entries.create!(:title => "The second entry",
                          :content => Faker::Lorem.sentence(100))
  end
end
