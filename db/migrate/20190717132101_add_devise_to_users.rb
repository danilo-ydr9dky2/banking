# frozen_string_literal: true

class AddDeviseToUsers < ActiveRecord::Migration[5.2]
  def self.up
    ## Database authenticatable
    #
    # Add NOT NULL and default option to email
    change_column :users, :email, :string, null: false, default: ""
    # Replace :password_digest with :encrypted_password
    remove_column :users, :password_digest, :string
    add_column :users, :encrypted_password, :string, null: false, default: ""

    # The index on users.email was not created to be unique
    remove_index :users, :email
    add_index :users, :email, unique: true
  end

  def self.down
    # By default, we don't want to make any assumption about how to roll back a migration when your
    # model already existed. Please edit below which fields you would like to remove in this migration.
    raise ActiveRecord::IrreversibleMigration
  end
end
