class Account < ApplicationRecord
  belongs_to :user

  # It will look like "9,99" and "0,01".
  # Note there will always be two digits after the comma.
  def balance
    reais = balance_in_cents / 100
    cents = balance_in_cents % 100
    zero = if cents < 10 then "0" else "" end
    "#{reais},#{zero}#{cents}"
  end

  # Adds the formatted balance in reais to the serialized JSON.
  def to_json(options = {})
    super(options.merge({ methods: [:balance] }))
  end
end
