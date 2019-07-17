class User < ApplicationRecord
  devise :database_authenticatable,
         :jwt_authenticatable, jwt_revocation_strategy: Devise::JWT::RevocationStrategies::Null
         #jwt_revocation_strategy: JWTBlacklist
  #has_secure_password

  validates :name, presence: true
  #validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  #validates_uniqueness_of :email
  #validates :password, length: { within: 6..40 }

  has_many :accounts
end
