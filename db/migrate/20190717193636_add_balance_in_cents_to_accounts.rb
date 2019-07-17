class AddBalanceInCentsToAccounts < ActiveRecord::Migration[5.2]
  def change
    remove_column :accounts, :balance, :integer
    add_column :accounts, :balance_in_cents, :integer, null: false, default: 0
  end
end
