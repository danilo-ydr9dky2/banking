class RemovePasswordDigestFromAccounts < ActiveRecord::Migration[5.2]
  def change
    remove_column :accounts, :password_digest
  end
end
