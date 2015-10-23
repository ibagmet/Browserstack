require 'rubygems'
require 'selenium-webdriver'
require 'test/unit'
require 'watir-webdriver'
require 'faker'

class GuessListBrCiTest < Test::Unit::TestCase
    include Selenium
    include GiftCardHelper

  def setup
    caps = WebDriver::Remote::Capabilities.new
    caps['project'] = ENV['BS_AUTOMATE_PROJECT'] if ENV['BS_AUTOMATE_PROJECT']
    caps['build'] = ENV['BS_AUTOMATE_BUILD'] if ENV['BS_AUTOMATE_BUILD']
    caps['name'] = 'Test <<Address Check List>>'
    caps['platform'] = ENV['SELENIUM_PLATFORM'] || 'ANY'
    caps['browser'] = ENV['SELENIUM_BROWSER'] || 'chrome'
    caps['browser_version'] = ENV['SELENIUM_VERSION'] if ENV['SELENIUM_VERSION']

    @browser = Watir::Browser.new(:remote,
    :url => "http://matthewredd:SPcNqvdg4Kd4qvjp294S@hub.browserstack.com/wd/hub",
    :desired_capabilities => caps)
    @base_url = 'https://deseretbook.net'
  end

  def test_guest_checkout
    empty_cart_t
    searching_for_dining
    billing_address_form
    and_credit_card
    confirmation_of_oder

    searching_for_dining
    billing_address_form
    and_gift_card
    gift_card_confirmation

    searching_for_dining
    billing_address_form
    and_gift_card_less_amount
    and_credit_card
    confirmation_of_oder
    that_s_it
  end

  def test_guest_cannot_check_out_with_digital_items
    empty_cart_t
    searching_for_dining_digital
    that_s_it
  end

  private

  def searching_for_dining
    @browser.text_field(name: "keywords").set 'Dining with the Prophets'
    @browser.input(class: "btn btn-primary img-responsive js-search-button").click
    assert(@browser.h1(text: "Search results for 'Dining with the Prophets'").exists?)
    @browser.img(alt: "Dining with the Prophets").click
    assert_equal("#{@base_url}/p/dining-prophets-lion-house-92869?variant_id=2692-hardcover", @browser.url, "incorrect location")
    @browser.button(class: "btn btn-lg btn-primary btn-block btn-add-to-cart").click
    assert_equal("#{@base_url}/item_added", @browser.url, "incorrect location")
    @browser.a(text: "Proceed to Checkout").click
    assert_equal("#{@base_url}/cart", @browser.url, "incorrect location")
    @browser.a(class: "btn btn-primary btn-lg pull-right btn-checkout").click
    assert_equal("#{@base_url}/checkout/registration", @browser.url, "incorrect location")
    email_new = ::Faker::Internet.email
    @browser.text_field(name: "order[email]").set email_new
    @browser.input(value: "Continue").click
    assert_equal("#{@base_url}/checkout", @browser.url, "incorrect location")
  end

  def searching_for_dining_digital
    @browser.text_field(name: "keywords").set 'Dining with the Prophets'
    @browser.input(class: "btn btn-primary img-responsive js-search-button").click
    assert(@browser.h1(text: "Search results for 'Dining with the Prophets'").exists?)
    @browser.img(alt: "Dining with the Prophets").click
    assert_equal("#{@base_url}/p/dining-prophets-lion-house-92869?variant_id=2692-hardcover", @browser.url, "incorrect location")
    @browser.span(text: "eBook").click
    @browser.button(class: "btn btn-lg btn-primary btn-block btn-add-to-cart").click
    assert_equal("#{@base_url}/item_added", @browser.url, "incorrect location")
    @browser.a(text: "Proceed to Checkout").click
    assert_equal("#{@base_url}/cart", @browser.url, "incorrect location")
    @browser.a(class: "btn btn-primary btn-lg pull-right btn-checkout").click
    assert_equal("#{@base_url}/checkout/registration", @browser.url, "incorrect location")
    assert_equal(@browser.div(class: 'flash error').text, "You must have an account to purchase ebooks. Sign in or create a new account.")
    sleep(1)
  end

  def billing_address_form
    @browser.text_field(name:"order[bill_address_attributes][firstname]").set ::Faker::Name.first_name  
    @browser.text_field(name:"order[bill_address_attributes][lastname]").set ::Faker::Name.name
    @browser.text_field(name:"order[bill_address_attributes][address1]").set ::Faker::Address.street_address
    @browser.text_field(name:"order[bill_address_attributes][address2]").set ::Faker::Address.secondary_address
    @browser.text_field(name:"order[bill_address_attributes][zipcode]").set ::Faker::Address.zip_code
    @browser.text_field(name:"order[bill_address_attributes][city]").set ::Faker::Address.city
    @browser.select(name:"order[bill_address_attributes][state_id]").select 'Colorado'
    @browser.text_field(name:"order[bill_address_attributes][phone]").set ::Faker::PhoneNumber.cell_phone
    @browser.label(text: "Use Billing Address").click
    @browser.button(class: "btn btn-primary pull-right js-form-validate btn-continue").click
    assert_equal("#{@base_url}/checkout/address", @browser.url, "incorrect location")
    @browser.button(class: "btn btn-primary pull-right js-form-validate btn-continue").click
    assert_equal("#{@base_url}/checkout/delivery", @browser.url, "incorrect location")
    @browser.button(class: "btn btn-primary pull-right btn-continue").click
    assert_equal("#{@base_url}/checkout/payment", @browser.url, "incorrect location")
  end

  def and_credit_card
    @browser.text_field(id: "name_on_card_2").set 'test user'
    @browser.text_field(id: "card_code").set '555'
    @browser.select(id: "date_month").select '1 - January'
    @browser.select(id: "date_year").select '2018'
    @browser.text_field(id: "card_number").set '4111111111111111'
    @browser.button(class: "btn btn-primary pull-right btn-continue js-submit-btn").click
  end

  def and_gift_card
    @browser.div(text: "Apply a Deseret Book Gift Card").click
    sleep(1) #for_aniamtion
    amount = get_new_gift_card_number(12.98)
    @browser.text_field(id: "gift_card_number_5").set amount
    @browser.button(class: "btn btn-primary js-apply-gift-card-btn").click
  end

  def and_gift_card_less_amount
    @browser.div(text: "Apply a Deseret Book Gift Card").click
    sleep(1) #for_aniamtion
    amount = get_new_gift_card_number(10)
    @browser.text_field(id: "gift_card_number_5").set amount
    @browser.button(class: "btn btn-primary js-apply-gift-card-btn").click
  end

  def gift_card_confirmation
    assert_equal("#{@base_url}/checkout/confirm", @browser.url, "incorrect location")
    @browser.button(class: "btn btn-primary btn-lg pull-right btn-continue").click
    assert_equal(@browser.div(class: 'flash notice').text, "Thank You. We have successfully received your order.")
  end     


  def confirmation_of_oder
    assert_equal("#{@base_url}/checkout/confirm", @browser.url, "incorrect location")
    @browser.button(class: "btn btn-primary btn-lg pull-right btn-continue").click
    assert_equal(@browser.div(class: 'flash notice').text, "Thank You. We have successfully received your order.")
  end

  def empty_cart_t
    @browser.goto  "#{base_url}/cart"
    @browser.input(value: "Empty Cart").click
  end

  def that_s_it
    puts @browser.title
    @browser.goto  "#{base_url}/logout"
    @browser.quit
  end
end
