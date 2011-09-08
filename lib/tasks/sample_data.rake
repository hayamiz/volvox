
namespace :db do
  desc "Fill database with sample data"
  task :populate => :environment do
    Rake::Task['db:reset'].invoke
    user = User.create!(:name			=> "Yuto HAYAMIZU",
                        :email			=> "info@hayamin.com",
                        :password		=> "hogehoge",
                        :password_confirmation	=> "hogehoge")
  end
end
