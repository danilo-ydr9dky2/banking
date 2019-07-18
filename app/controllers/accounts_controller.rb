class AccountsController < ApplicationController
  class InsufficientFundsError < StandardError
    def initialize
      super("source account has insufficient funds to proceed with this transaction")
    end
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
  #   - amount: string - amount of reais (BRL) to be transferred, like "9,99"
  def transfer
    source_account = Account.find_by(id: params['account_id'])
    destination_account = Account.find_by(id: params['destination_account_id'])

    # Return 404 in case neither source nor destination accounts are found
    return not_found unless source_account.present? and destination_account.present?
    # Return 403 in case the source account isn't owned by the logged in user
    return forbidden unless source_account.user == current_user

    # Makes sure amount is in the right format
    amount_in_cents = parse_amount(params)
    if amount_in_cents.nil?
        return render json: { errors: ["amount must be in the format 9,99"] }, status: :bad_request
    end

    # Create credit and debit transactions within a transaction
    Account.transaction do
      # Hold locks on both accounts while the transactions are being created
      Account.lock_for_update(source_account, destination_account)

      raise InsufficientFundsError.new unless source_account.has_funds?(amount_in_cents)

      debit = Transaction.create(
        account_id: source_account.id,
        amount_in_cents: amount_in_cents,
        kind: :debit
      )
      debit.save!
      source_account.last_transaction_at = debit.created_at
      source_account.save!
      credit = Transaction.create(
        account_id: destination_account.id,
        amount_in_cents: amount_in_cents,
        kind: :credit
      )
      credit.save!
      destination_account.last_transaction_at = credit.created_at
      destination_account.save!
    rescue InsufficientFundsError => e
      return render json: { errors: [e.message] }, status: :forbidden
    end

    render json: { status: "success" }, status: :ok
  end

  # DELETE /accounts/:id
  def destroy
    account = Account.find_by(id: params['id'])
    return not_found unless account.present?
    return forbidden unless account.user == current_user
    account.destroy
  end

  private

  # It parses string amounts like "9,99" and it returns the amount in cents as an integer
  def parse_amount(params)
    return unless params['amount'].present?
    match_data = params['amount'].to_s.match(/(\d+),(\d{2})/)
    return unless match_data.present?
    match_data[1].to_i * 100 + match_data[2].to_i
  end
end
