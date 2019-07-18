class Account < ApplicationRecord
  belongs_to :user
  has_many :transactions

  #TODO: use ActiveRecord caching instead
  @cents = nil

  def balance
    format_to_reais(balance_in_cents)
  end

  def balance_in_cents
    return @cents unless @cents.nil?
    @cents = fetch_balance_in_cents
  end

  def has_funds?(amount_in_cents)
    amount_in_cents <= balance_in_cents
  end

  # Adds the formatted balance in reais to the serialized JSON.
  def to_json(options = {})
    super(options.merge({ except: [:last_transaction_at], methods: [:balance, :balance_in_cents] }))
  end

  def self.lock_for_update(*accounts)
    # it sorts accounts by id first to prevent deadlocks
    sorted_by_id = accounts.sort { |a, b| a.id <=> b.id }
    # lock! yields a SELECT FOR UPDATE on Postgresql
    sorted_by_id.each(&:lock!)
  end

  private

  def fetch_balance_in_cents
    total_by_kind = Transaction.select(:amount_in_cents).where(account_id: id).group(:kind).sum(:amount_in_cents)
    credit = total_by_kind['credit'] or 0
    debit = total_by_kind['debit'] or 0
    credit.to_i - debit.to_i
  end

  # It will look like "9,99" and "0,01".
  # Note there will always be two digits after the comma.
  def format_to_reais(amount_in_cents)
    reais = amount_in_cents / 100
    cents = amount_in_cents % 100
    zero = if cents < 10 then "0" else "" end
    "#{reais},#{zero}#{cents}"
  end
end
