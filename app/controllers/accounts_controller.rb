class AccountsController < ApplicationController
  class InsufficientFundsError < StandardError
  end

  before_action :authenticate_user!

  # GET /users/:user_id/accounts
  def index
    user = User.find_by(id: params['user_id'])
    return not_found unless user.present?
    return forbidden unless user == current_user
    render json: { accounts: user.accounts }
  end

  # POST /users/:user_id/accounts
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

  # GET /accounts/:id
  def show
    account = Account.find_by(id: params['id'])
    return not_found unless account.present?
    return forbidden unless account.user == current_user
    render json: account
  end

  # GET /accounts/:account_id/balance
  def balance
    account = Account.find_by(id: params['account_id'])
    return not_found unless account.present?
    return forbidden unless account.user == current_user
    render json: { balance: account.balance, balance_in_cents: account.balance_in_cents }
  end

  # POST /accounts/:account_id/transfer/:destination_account_id
  #
  # Request body:
  #     - amount: string - amount of reais (BRL) to be transferred, like "9,99"
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

    # Makes sure amount is in the right format
    amount = parse_amount(params)
    if amount.nil?
        return render json: { errors: ["amount must be in the format 9,99"] }, status: :bad_request
    end

    # Update `balance_in_cents` within a transaction
    Account.transaction do
      if source_account.balance_in_cents < amount
        raise InsufficientFundsError.new("source account has insufficient funds to proceed with this transaction")
      end
      source_account.balance_in_cents -= amount
      destination_account.balance_in_cents += amount
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

  private

  def parse_amount(params)
    return unless params['amount'].present?
    match_data = params['amount'].to_s.match(/(\d+),(\d{2})/)
    return unless match_data.present?
    match_data[1].to_i * 100 + match_data[2].to_i
  end
end
