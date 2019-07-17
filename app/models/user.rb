class User < ApplicationRecord
  # Note we are not using any revocation strategy
  # there is a good discussion about it at http://waiting-for-dev.github.io/blog/2017/01/24/jwt_revocation_strategies/
  devise :database_authenticatable,
         :jwt_authenticatable, jwt_revocation_strategy: Devise::JWT::RevocationStrategies::Null

  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { within: 6..40 }

  has_many :accounts
end
