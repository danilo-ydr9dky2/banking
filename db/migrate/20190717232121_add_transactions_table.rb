class AddTransactionsTable < ActiveRecord::Migration[5.2]
  def up
    create_table :transactions do |t|
      t.bigint :amount_in_cents, null: false, default: 0
      t.integer :kind, null: false  # credit or debit
      t.datetime :created_at, null: false
    end

    add_reference :transactions, :account, foreign_key: true, index: true
  end

  def down
    drop_table :transactions
  end
end
