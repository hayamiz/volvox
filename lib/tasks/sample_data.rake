
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
    61.times do |n|
      diary.entries.create!(:date => Date.today - n,
                            :memo => Faker::Lorem.paragraphs(5).join("\n\n"))
    end
  end
end
