class CreateAccounts < ActiveRecord::Migration[5.2]
  def change
    create_table :accounts do |t|
      t.string :password_digest
      t.float :balance

      t.timestamps
    end
  end
end
