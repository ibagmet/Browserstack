module StandardCheckoutHelper

  def standard_checkout_workflow(login_type: :before, item_type: [:physical, :digital], payment_type: :credit_card, physical_quantity: 1)
    item_type = Array(item_type) # ensure item_type is an array.
    payment_type = Array(payment_type) # ensure payment_type is an array.
    start_new_order_log(
      login_type: login_type,
      item_type: item_type,
      payment_type: payment_type,
      physical_quantity: physical_quantity
    )

    clear_cookies
    if login_type == :before
      login
      empty_cart
    end

    add_items_to_cart(item_type, physical_quantity: physical_quantity)

    begin_checkout

    if login_type == :during
      # .when_present below because the field may take a moment to appear
      browser.text_field(name: "spree_user[email]").when_present.set 'tests@deseretbook.com'
      browser.text_field(name: "spree_user[password]").set 'test123'
      browser.input(name: "commit").when_present.click
      if item_type.include?(:digital)
        browser.button(id: "checkout-link").click
        browser.button(id: "checkout-link").wait_while_present
      end
    end

    select_addresses(allow_skip: true)

    select_delivery(allow_skip: true) if item_type.include? :physical

    select_payment(payment_type: payment_type, allow_skip: true)

    confirm_order
    verify_successful_order
    verify_order_state(item_type)
    order_finished
  end

  def select_addresses(allow_skip: false)
    if allow_skip
      # if we're only doing digital items, there is a chance we'll be sent to
      # the select payment page instead; this is normal. If so, allow this step
      # to be skipped.
      return if browser.url == "#{base_url}/checkout/payment"
    else
      assert_equal("#{base_url}/checkout/address", browser.url, "incorrect location")
    end

    # FIXME the lines below are commented out until we know the correct behaviour of the select address page.

    # # The element below won't be found if the user has no saved address.
    # browser.element(xpath: "//fieldset[@id='billing']/div[@class='select_address']/div[1]/label/input").click

    # if !browser.input(id: "order_use_billing").checked?
    #   browser.element(xpath: "//fieldset[@id='shipping']/div[@class='select_address']/div[1]/label/input").click
    # end

    # browser.button(text: 'Continue').click
  end

  def select_payment(payment_type: :credit_card, gift_card_type: :valid, allow_skip: false)
    if allow_skip
      # if we're only doing digital items, there is a chance we'll be sent to
      # the select comfirmation page instead; this is normal. If so, allow this step
      # to be skipped.
      return if browser.url == "#{base_url}/checkout/confirm"
    else
      assert (browser.url == "#{base_url}/checkout/payment"), "url should be /checkout/payment"
    end

    payment_type = Array(payment_type) # ensure payment_type is an array.

    # if this is a multiple tender order, we must enter the gift-card first.
    number_of_gift_cards(payment_type).times do |i|
      order_total = get_order_total_from_payment_summary
      gift_card_amount = if payment_type.include?(:credit_card)
        # split payment, this gift card should be less than the order total
        # so that we can also apply a credit card.
        order_total / (number_of_gift_cards(payment_type)+1)
      else
        # single payment type order
        order_total / number_of_gift_cards(payment_type)
      end.round(2)

      if i == 0 # if this is the first gift card payment of the order
        # For orders that don't include a credit card, we need to check for
        # rounding errors that can happen when calculating how big each gift
        # card should be. This is not necessary if we're also using a credit
        # card because it will "soak up" the rounding issue.
        unless payment_type.include?(:credit_card)
          if (rounding_error = order_total - (gift_card_amount * number_of_gift_cards(payment_type))) > 0.0
            # if we find a rounding error, make the total for this card
            # big enough to cover it.
            gift_card_amount += rounding_error
          end
        end
      end

      number = gift_card_number(
        type: gift_card_type,
        amount: gift_card_amount
      )

      # click the "Gift Card" radio button
      browser.element(css: 'input[data-method-type="gift_card"]').click

      browser.text_field(
        id: browser.label(text: 'Gift Card Number').for
      ).set number
      order_log(gift_card_number: number)

      # click the "apply to order" button for the gift card
      browser.button(class: "js-apply-gift-card-btn")
    end

    if payment_type.include?(:credit_card)
      if browser.label(class: 'existing-cc-method').present?
        unless browser.label(class: 'existing-cc-method').input(type: 'radio').checked?
          browser.label(class: 'existing-cc-method').input(type: 'radio').click
        end
        order_log(credit_card_number: :saved_number)
      else
        # This is the "Credit Card" radio button on Payment Information page.
        browser.input(
          id: 'select_payment_method_spree_gateway_braintree_gateway_2'
        ).click
        browser.text_field(
          id: browser.label(text: 'Name on card').for
        ).set 'test user'
        browser.text_field(
          id: browser.label(text: 'Card Number').for
        ).set '4111111111111111'
        browser.select(id: 'date_month').option(text: '1 - January').select
        browser.select(id: 'date_year').option(text: '2018').select
        browser.text_field(
          id: browser.label(text: 'Card Code').for
        ).set '555'
        order_log(credit_card_number: '4111111111111111')
      end
      browser.button(text: 'Continue').click
    end
  end

  def number_of_gift_cards(payment_type)
    payment_type.each_with_object([0]) { |type,counts| counts[0]+=1 if type == :gift_card }.first
  end
end

