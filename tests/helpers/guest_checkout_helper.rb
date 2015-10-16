module GuestCheckoutHelper
  

  def guest_checkout_workflow(item_type: [:physical, :digital], use_billing_address: true, payment_type: :credit_card)
    item_type = Array(item_type) # ensure item_type is an array.
    payment_type = Array(payment_type) # ensure payment_type is an array.
    start_new_order_log(
      use_billing_address: use_billing_address,
      item_type: item_type,
      payment_type: payment_type
    )
    clear_cookies

    add_items_to_cart(item_type)

    begin_checkout
    checkout_as_guest
    input_guest_addresses(use_billing_address)

    select_delivery if item_type.include? :physical

    pay_with_credit_card if payment_type.include?(:credit_card)
    pay_with_gift_card if payment_type.include?(:gift_card)

    confirm_order
    verify_successful_order
    get_order_number
    order_finished
  end


  def checkout_as_guest
    assert (browser.url == "#{base_url}/checkout/registration"), "url should be /checkout/registration"

    browser.text_field(name: "order[email]").set 'tests@deseretbook.com'
    browser.form(id: "checkout_form_registration").submit
  end

  def input_guest_addresses(use_billing_address = true)
    assert (browser.url == "#{base_url}/checkout"), "url should be /checkout"

    browser.text_field(name: "order[bill_address_attributes][firstname]").set 'test'
    browser.text_field(name: "order[bill_address_attributes][lastname]").set 'user'
    browser.text_field(name: "order[bill_address_attributes][address1]").set '1445 K St'
    browser.text_field(name: "order[bill_address_attributes][city]").set 'Lincoln'
    browser.select_list(name: "order[bill_address_attributes][state_id]").select 'Nebraska'
    browser.text_field(name: "order[bill_address_attributes][zipcode]").set '68508'
    browser.text_field(name: "order[bill_address_attributes][phone]").set '555-5555'
    
    if use_billing_address
      browser.input(id: "order_use_billing").click
    else
      browser.text_field(name: "order[ship_address_attributes][firstname]").set 'test'
      browser.text_field(name: "order[ship_address_attributes][lastname]").set 'user'
      browser.text_field(name: "order[ship_address_attributes][address1]").set '1445 K St'
      browser.text_field(name: "order[ship_address_attributes][city]").set 'Lincoln'
      browser.select_list(name: "order[ship_address_attributes][state_id]").select 'Nebraska'
      browser.text_field(name: "order[ship_address_attributes][zipcode]").set '68508'
      browser.text_field(name: "order[ship_address_attributes][phone]").set '555-5555'
    end

    browser.input(name: "commit").when_present.click
  end

  def pay_with_credit_card
    assert (browser.url == "#{base_url}/checkout/payment"), "url should be /checkout/payment"

    browser.label(text: 'Credit Card').input(type: 'radio').click
    browser.text_field(id: "card_number").set '4111111111111111'
    browser.text_field(id: "card_expiry").set '01/18'
    browser.text_field(id: "card_code").set '555'

    order_log(credit_card_number: '4111111111111111')

    browser.input(name: "commit").when_present.click    
  end

  def pay_with_gift_card
    assert (browser.url == "#{base_url}/checkout/payment"), "url should be /checkout/payment"

    browser.label(text: 'Gift Card').input(type: 'radio').click

    number = gift_card_number(amount: get_order_total_from_payment_summary)

    # find the Gift Card Number text field by looking at the 'for' property
    # of the label with the text 'Gift Card Number'
    browser.text_field(
      id: browser.label(text: 'Gift Card Number').for
    ).set number
    order_log(gift_card_number: number)

    browser.input(name: "commit").when_present.click    
  end

  def assert_checkout_as_guest_form_is_disabled
    assert_equal("#{base_url}/checkout/registration", browser.url, 'expected to be on checkout registration page')

    # assert that the correct error message is shown
    assert(
      browser
        .div(id: 'guest_checkout')
        .div(class: 'flash error')
        .text
        .include?('You must have an account to purchase ebooks')
    )
      
    # assert the email entry field is disabled
    assert(
      browser.text_field(
        id: browser.div(id: 'guest_checkout').label(text: 'Email').for
      ).disabled?
    )

    # assert the submit button for that form is disabled
    assert(
      browser.div(id: 'guest_checkout').form.input(type: 'submit').disabled?
    )
  end
end
