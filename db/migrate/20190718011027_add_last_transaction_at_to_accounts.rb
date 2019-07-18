class AddLastTransactionAtToAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :last_transaction_at, :datetime
  end
end
