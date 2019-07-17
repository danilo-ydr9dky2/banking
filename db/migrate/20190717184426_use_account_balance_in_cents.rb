class UseAccountBalanceInCents < ActiveRecord::Migration[5.2]
  def change
    change_column :accounts, :balance, :integer, null: false, default: 0
  end
end
