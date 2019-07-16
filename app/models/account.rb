class Account < ApplicationRecord
  class InsufficientFundsError < StandardError
  end

  belongs_to :user
end
