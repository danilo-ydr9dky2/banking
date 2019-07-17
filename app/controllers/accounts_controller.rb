class AccountsController < ApplicationController
  class InsufficientFundsError < StandardError
  end

  before_action :authenticate_user!

  def index
    user = User.find_by(id: params['user_id'])
    return not_found unless user.present?
    return forbidden unless user == current_user
    render json: { accounts: user.accounts }
  end

  def create
    user = User.find_by(id: params['user_id'])
    return not_found unless user.present?
    return forbidden unless user == current_user
    account = Account.create(user_id: user.id)
    if account.valid?
      render json: account
    else
      render json: { errors: account.errors.messages }, status: :bad_request
    end
  end

  def show
    account = Account.find_by(id: params['id'])
    return not_found unless account.present?
    return forbidden unless account.user == current_user
    render json: account
  end

  def balance
    account = Account.find_by(id: params['account_id'])
    return not_found unless account.present?
    return forbidden unless account.user == current_user
    render json: { balance: account.balance }
  end

  def transfer
    source_id = params['account_id'].try(:to_i)
    dest_id = params['destination_account_id'].try(:to_i)

    # Account.lock yields a SELECT FOR UPDATE on Postgresql
    accounts_hash = Account.lock.where(
      id: [source_id, dest_id]
    ).to_h { |act| [act.id, act] }
    source_account = accounts_hash[source_id]
    destination_account = accounts_hash[dest_id]

    # Return 404 in case neither source nor destination accounts are found
    return not_found unless source_account.present? and destination_account.present?
    # Return 403 in case the source account isn't owned by the logged in user
    return forbidden unless source_account.user == current_user

    # TODO: implement amount validation
    amount = params['amount'].to_f

    # Update balances within a transaction
    Account.transaction do
      if source_account.balance < amount
        raise InsufficientFundsError.new("source account has insufficient funds to proceed with this transaction")
      end
      source_account.balance -= amount
      destination_account.balance += amount 
      source_account.save!
      destination_account.save!
    rescue InsufficientFundsError => e
      return render json: { errors: [e.message] }, status: :forbidden
    end

    render json: { status: "success" }, status: :ok
  end

  def destroy
    account = Account.find_by(id: params['id'])
    return not_found unless account.present?
    return forbidden unless account.user == current_user
    account.destroy
  end
end
