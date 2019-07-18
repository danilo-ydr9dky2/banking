class RemoveBalanceFromAccounts < ActiveRecord::Migration[5.2]
  def change
    remove_column :accounts, :balance_in_cents, :integer
  end
end
