# TODO: implement authentication
class AccountsController < ApplicationController
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
    account = Account.find_by(id: params['id'], user_id: params['user_id'])
    return not_found unless account.present?
    render json: account
  end

  def balance
    account = Account.find_by(id: params['account_id'], user_id: params['user_id'])
    return not_found unless account.present?
    render json: { balance: account.balance }
  end

  def transfer
    # TODO: implement this
  end

  def destroy
    account = Account.find_by(id: params['id'], user_id: params['user_id'])
    return not_found unless account.present?
    account.destroy
  end
end
