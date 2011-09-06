# == Schema Information
#
# Table name: users
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime
#  updated_at :datetime
#

require 'digest'

class User < ActiveRecord::Base
  attr_accessor :password
  attr_accessible :name, :email, :password, :password_confirmation, :salt

  email_regex = %r{
    ^ # Start of string
    [0-9a-z] # First character
    [0-9a-z.+]+ # Middle characters
    [0-9a-z] # Last character
    @ # Separating @ character
    [0-9a-z] # Domain name begin
    [0-9a-z.-]+ # Domain name middle
    [0-9a-z] # Domain name end
    $ # End of string
  }xi # Case insensitive

  validates(:name,
            :presence => true,
            :length => { :maximum => 255 })
  validates(:email,
            :presence => true,
            :format => { :with => email_regex },
            :uniqueness => { :case_sensitive => false })
  validates(:password,
            :presence		=> true,
            :confirmation	=> true,
            :length		=> {:within => 6..40})
  before_save :encrypt_password

  class << self
    def authenticate(email, submitted_password)
      user = find_by_email(email)
      return nil if user.nil?
      return user if user.has_password?(submitted_password)
    end

    def authenticate_with_salt(id, cookie_salt)
      user = find_by_id(id)
      (user && user.salt == cookie_salt) ? user : nil
    end
  end

  def has_password?(submitted_password)
    self.encrypted_password == encrypt(submitted_password)
  end

  private
  def encrypt_password
    self.salt = make_salt if new_record?
    self.encrypted_password = encrypt(self.password)
  end

  def encrypt(str)
    secure_hash("#{salt}--#{str}")
  end

  def make_salt
    secure_hash("#{Time.now.utc}--#{self.password}")
  end

  def secure_hash(str)
    Digest::SHA2.hexdigest(str)
  end
end
