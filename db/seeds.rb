# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).

alice = User.create(name: "Alice", email: "alice@email.com", password: "secret")
bob = User.create(name: "Bob", email: "bob@email.com", password: "secret")

alice_account = Account.create(user: alice)
bob_account = Account.create(user: bob)

Transaction.create(account: alice_account, amount_in_cents: 100, kind: :credit)
Transaction.create(account: bob_account, amount_in_cents: 50, kind: :credit)
