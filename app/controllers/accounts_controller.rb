# TODO: implement authentication
class AccountsController < ApplicationController
  class InsufficientFundsError < StandardError
  end

  def index
    user = User.find_by(id: params['user_id'])
    return not_found unless user.present?
    render json: { accounts: user.accounts }
  end

  def create
    user = User.find_by(id: params['user_id'])
    return not_found unless user.present?
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
    render json: account
  end

  def balance
    account = Account.find_by(id: params['account_id'])
    return not_found unless account.present?
    render json: { balance: account.balance }
  end

  # TODO: implement amount validation
  def transfer
    source_account = Account.find_by(id: params['account_id'])
    destination_account = Account.find_by(id: params['destination_account_id'])
    return not_found unless source_account.present? and destination_account.present?

    amount = params['amount'].to_f
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
    account.destroy
  end
end
