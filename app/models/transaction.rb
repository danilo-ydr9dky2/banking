class Transaction < ApplicationRecord
  belongs_to :account
  enum kind: [:credit, :debit]
end
