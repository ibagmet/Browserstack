require 'httparty'
require 'json'

module GiftCardHelper
  # TODO instead of a static number for :insufficient_funds, just generate
  # a gift card with a zero-dollar balance.
  NUMBERS = {
    insufficient_funds: %w[ R299267428027 ],
    invalid: %w[ R99999INVALID ]
  }
  def gift_card_number(type: :valid, amount: nil)
    case type
    when :valid
      get_new_gift_card_number(amount)
    else
      NUMBERS[type]
    end
  end


  def get_new_gift_card_number(amount)
    body = { amount: amount.to_f.round(2) }.to_json
    # puts "Gift Card request: #{body}"
    result = HTTParty.post("#{base_url}/api/fake_gift_card/create",
      body: body,
      verify: false, # SSL cert on stage may be invalid, so don't try to validate it.
      headers: {
        'Content-Type' => 'application/json',
        'Accept' => 'application/json'
      }
    )

    result = JSON.parse(result.body)
    # puts "Gift Card response: #{result.inspect}"
    order_log(gift_card_transaction: result)
    result['card_number']
  end
end
