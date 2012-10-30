class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :token_authenticatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  attr_accessible :provider, :uid
  attr_accessible :first_name, :last_name, :role, :karma, :account_id

  belongs_to :account
  has_many :ideas
  has_many :votes
  has_many :comments, :as => :author
  has_many :notifications


  def self.find_or_create_from_auth_hash!(auth_hash)
    if user = self.where(uid: auth_hash[:uid]).first
      return user
    end

    self.new.tap do |user|
      if auth_hash[:info][:first_name]
        user.first_name = auth_hash[:info][:first_name]
        user.last_name  = auth_hash[:info][:last_name]
      elsif auth_hash[:info][:name] =~ /(.*?)\s+(.*)/
        user.first_name = $1.strip
        user.last_name  = $2.strip
      else
        user.first_name = auth_hash[:info][:name].strip
      end

      user.email    = auth_hash[:info][:email]
      user.provider = auth_hash[:provider]
      user.uid      = auth_hash[:uid]
      user.password = SecureRandom.base64
      user.save!
    end
  end
end
