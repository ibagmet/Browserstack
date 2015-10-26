require 'rubygems'
require 'selenium-webdriver'
require 'test/unit'
require 'watir-webdriver'
require 'faker'
require 'httparty'
require 'json'

class GuessListBrCiTest < Test::Unit::TestCase
    include Selenium

NUMBERS = {
    insufficient_funds: %w[ R299267428027 ],
    invalid: %w[ R99999INVALID ]
  }

  def setup
    caps = WebDriver::Remote::Capabilities.new
    caps['project'] = ENV['BS_AUTOMATE_PROJECT'] if ENV['BS_AUTOMATE_PROJECT']
    caps['build'] = ENV['BS_AUTOMATE_BUILD'] if ENV['BS_AUTOMATE_BUILD']
    caps['name'] = 'Test <<Standard CheckOut>>'
    caps['platform'] = ENV['SELENIUM_PLATFORM'] || 'ANY'
    caps['browser'] = ENV['SELENIUM_BROWSER'] || 'chrome'
    caps['browser_version'] = ENV['SELENIUM_VERSION'] if ENV['SELENIUM_VERSION']

    @browser = Watir::Browser.new(:remote,
    :url => "http://matthewredd:SPcNqvdg4Kd4qvjp294S@hub.browserstack.com/wd/hub",
    :desired_capabilities => caps)
    @base_url = 'https://deseretbook.net'
  end

  def test_guest_checkout_physical_item
    empty_cart_t
    searching_for_dining
    billing_address_form
    delivery_options
    and_credit_card
    confirmation_of_oder
    logout
    
    searching_for_dining
    billing_address_form
    delivery_options   
    and_gift_card
    gift_card_confirmation
    logout

    searching_for_dining
    billing_address_form
    delivery_options
    and_gift_card_less_amount
    and_credit_card
    confirmation_of_oder
    logout

    searching_for_dining_with_more_amount
    billing_address_form
    delivery_options
    and_gift_card
    and_gift_card_number_two
    gift_card_confirmation
    logout

    searching_for_dining_with_more_amount
    billing_address_form
    delivery_options  
    and_gift_card_less_amount
    and_gift_card_number_two
    and_credit_card
    confirmation_of_oder
    logout

    searching_for_dining_with_more_amount
    billing_address_form
    delivery_options
    and_gift_card_less_amount
    and_gift_card_number_two
    and_gift_card_number_three
    gift_card_confirmation
    logout
    that_s_it
  end
  
  def test_guest_checkout_digital_item
    empty_cart_t
    searching_for_dining_digital
    billing_address_form
    and_credit_card
    confirmation_of_oder
    logout
    
    searching_for_dining_digital
    billing_address_form
    and_gift_card
    gift_card_confirmation
    logout

    searching_for_dining_digital
    billing_address_form
    and_gift_card_less_amount
    and_credit_card
    confirmation_of_oder
    logout

    searching_for_dining_with_more_amount_digital
    procced_to_checkout
    billing_address_form
    and_gift_card
    and_gift_card_number_two
    gift_card_confirmation
    logout

    searching_for_dining_with_more_amount_digital
    procced_to_checkout
    billing_address_form
    and_gift_card
    and_gift_card_less_amount
    and_credit_card
    confirmation_of_oder
    logout

    searching_for_dining_with_more_amount_digital
    searching_for_God_Remembered_Me_digital
    procced_to_checkout
    billing_address_form
    and_gift_card_less_amount
    and_gift_card_number_two
    and_gift_card_number_three
    gift_card_confirmation
    logout
    that_s_it
  end

  def test_guest_checkout_physical_and_digital_items
    empty_cart_t
    searching_for_dining_and_digital
    procced_to_checkout
    billing_address_form
    delivery_options
    and_credit_card
    confirmation_of_oder
    logout

    searching_for_dining_and_digital
    procced_to_checkout
    billing_address_form
    delivery_options
    and_gift_card_number_one
    gift_card_confirmation
    logout

    searching_for_dining_and_digital
    procced_to_checkout
    billing_address_form
    delivery_options
    and_gift_card_less_amount
    and_credit_card
    confirmation_of_oder
    logout

    searching_for_dining_and_digital
    procced_to_checkout
    billing_address_form
    delivery_options
    and_gift_card
    and_gift_card_number_two
    gift_card_confirmation
    logout

    searching_for_dining_and_digital
    procced_to_checkout
    billing_address_form
    delivery_options
    and_gift_card_less_amount
    and_gift_card_number_two
    and_credit_card
    confirmation_of_oder
    logout

    searching_for_dining_and_digital
    procced_to_checkout
    billing_address_form
    delivery_options
    and_gift_card_less_amount
    and_gift_card_number_two
    and_gift_card_number_three
    gift_card_confirmation
    logout
    that_s_it
  end

  def test_checkout_physical_item_login_before_checkout
    sigin_up
    empty_cart_t
    searching_for_dining_login
    billing_address_form
    delivery_options
    and_credit_card
    confirmation_of_oder
    logout
    
    sigin_up
    searching_for_dining_login
    billing_address_form
    delivery_options
    and_gift_card
    gift_card_confirmation
    logout

    sigin_up
    searching_for_dining_login
    billing_address_form
    delivery_options
    and_gift_card_less_amount
    and_credit_card
    confirmation_of_oder
    logout

    sigin_up
    searching_for_dining_login
    billing_address_form
    delivery_options
    and_gift_card_less_amount
    and_gift_card_number_three
    gift_card_confirmation
    logout

    sigin_up
    searching_for_dining_with_more_amount_login
    billing_address_form
    delivery_options
    and_gift_card_less_amount
    and_gift_card_number_two
    and_credit_card
    confirmation_of_oder
    logout

    sigin_up
    searching_for_dining_with_more_amount_login
    billing_address_form
    delivery_options
    and_gift_card_less_amount
    and_gift_card_number_two
    and_gift_card_number_three
    gift_card_confirmation
    logout
    that_s_it
  end

  def test_checkout_digital_item_login_before_checkout
    sigin_up
    empty_cart_t
    searching_for_dining_digital_login
    billing_address_form
    and_credit_card
    confirmation_of_oder
    logout
    
    sigin_up
    searching_for_dining_digital_login
    billing_address_form
    and_gift_card
    gift_card_confirmation
    logout

    sigin_up
    searching_for_dining_digital_login
    billing_address_form
    and_gift_card_less_amount
    and_credit_card
    confirmation_of_oder
    logout
    
    sigin_up
    searching_for_dining_with_more_amount_digital
    procced_to_checkout_login
    billing_address_form
    and_gift_card
    and_gift_card_number_two
    gift_card_confirmation
    logout

    sigin_up
    searching_for_dining_with_more_amount_digital
    searching_for_God_Remembered_Me_digital
    procced_to_checkout_login
    billing_address_form
    and_gift_card_less_amount
    and_gift_card_number_two
    and_credit_card
    confirmation_of_oder
    logout

    sigin_up
    searching_for_dining_with_more_amount_digital
    searching_for_God_Remembered_Me_digital
    procced_to_checkout_login
    billing_address_form
    and_gift_card_less_amount
    and_gift_card_number_two
    and_gift_card_number_three
    gift_card_confirmation
    logout
    that_s_it
  end
  
  def test_checkout_physical_and_digital_items_login
    sigin_up
    empty_cart_t
    searching_for_dining_and_digital
    procced_to_checkout_login
    billing_address_form
    delivery_options
    and_credit_card
    confirmation_of_oder
    logout

    sigin_up
    searching_for_dining_and_digital
    procced_to_checkout_login
    billing_address_form
    delivery_options
    and_gift_card_number_one
    gift_card_confirmation
    logout
    
    sigin_up
    searching_for_dining_and_digital
    procced_to_checkout_login
    billing_address_form
    delivery_options
    and_gift_card_less_amount
    and_credit_card
    confirmation_of_oder
    logout

    sigin_up
    searching_for_dining_and_digital
    procced_to_checkout_login
    billing_address_form
    delivery_options
    and_gift_card
    and_gift_card_number_two
    gift_card_confirmation
    logout

    sigin_up
    searching_for_dining_and_digital
    procced_to_checkout_login
    billing_address_form
    delivery_options
    and_gift_card_less_amount
    and_gift_card_number_two
    and_credit_card
    confirmation_of_oder
    logout

    sigin_up
    searching_for_dining_and_digital
    procced_to_checkout_login
    billing_address_form
    delivery_options
    and_gift_card_less_amount
    and_gift_card_number_two
    and_gift_card_number_three
    gift_card_confirmation
    logout
    that_s_it
  end

  private

  def sigin_up
    @browser.goto  "#{@base_url}/signup"
    @browser.text_field(name: "spree_user[email]").set ::Faker::Internet.email
    @browser.text_field(name: "spree_user[first_name]").set ::Faker::Name.first_name
    @browser.text_field(name: "spree_user[last_name]").set ::Faker::Name.last_name
    password = ::Faker::Number.number(5)
    @browser.text_field(name: "spree_user[password]").set password
    @browser.text_field(name: "spree_user[password_confirmation]").set password
    @browser.input(name: "commit").click
    assert(@browser.div(class: 'flash notice').present?)
  end
    
  def searching_for_dining_login
    @browser.text_field(name: "keywords").set 'Dining with the Prophets'
    @browser.input(class: "btn btn-primary img-responsive js-search-button").click
    assert(@browser.h1(text: "Search results for 'Dining with the Prophets'").exists?)
    @browser.img(alt: "Dining with the Prophets").click
    assert_equal("#{@base_url}/p/dining-prophets-lion-house-92869?variant_id=2692-hardcover", @browser.url, "incorrect location")
    @browser.button(class: "btn btn-lg btn-primary btn-block btn-add-to-cart").click
    assert_equal("#{@base_url}/item_added", @browser.url, "incorrect location")
    go_to_cart
    @browser.a(class: "btn btn-primary btn-lg pull-right btn-checkout").click
  end

  def searching_for_dining_with_more_amount_login
    @browser.text_field(name: "keywords").set 'Dining with the Prophets'
    @browser.input(class: "btn btn-primary img-responsive js-search-button").click
    assert(@browser.h1(text: "Search results for 'Dining with the Prophets'").exists?)
    @browser.img(alt: "Dining with the Prophets").click
    assert_equal("#{@base_url}/p/dining-prophets-lion-house-92869?variant_id=2692-hardcover", @browser.url, "incorrect location")
    @browser.button(class: "btn btn-lg btn-primary btn-block btn-add-to-cart").click
    assert_equal("#{@base_url}/item_added", @browser.url, "incorrect location")
    
    @browser.text_field(name: "keywords").set 'The Romney Family Table'
    @browser.input(class: "btn btn-primary img-responsive js-search-button").click
    assert(@browser.h1(text: "Search results for 'The Romney Family Table'").exists?)
    @browser.img(alt: "The Romney Family Table").click
    assert_equal("#{@base_url}/p/romney-family-table-ann-89648?variant_id=6324-hardcover", @browser.url, "incorrect location")
    @browser.button(class: "btn btn-lg btn-primary btn-block btn-add-to-cart").click
    assert_equal("#{@base_url}/item_added", @browser.url, "incorrect location")
    go_to_cart
    @browser.a(class: "btn btn-primary btn-lg pull-right btn-checkout").click
  end

  def searching_for_dining
    @browser.text_field(name: "keywords").set 'Dining with the Prophets'
    @browser.input(class: "btn btn-primary img-responsive js-search-button").click
    assert(@browser.h1(text: "Search results for 'Dining with the Prophets'").exists?)
    @browser.img(alt: "Dining with the Prophets").click
    assert_equal("#{@base_url}/p/dining-prophets-lion-house-92869?variant_id=2692-hardcover", @browser.url, "incorrect location")
    @browser.button(class: "btn btn-lg btn-primary btn-block btn-add-to-cart").click
    assert_equal("#{@base_url}/item_added", @browser.url, "incorrect location")
    go_to_cart
    @browser.a(class: "btn btn-primary btn-lg pull-right btn-checkout").click
    assert_equal("#{@base_url}/checkout/registration", @browser.url, "incorrect location")
    browser.a(text: "Create a new account").click
    assert_equal("#{@base_url}/signup", @browser.url, "incorrect location")
    @browser.text_field(name: "spree_user[email]").set ::Faker::Internet.email
    @browser.text_field(name: "spree_user[first_name]").set 'test_name'
    @browser.text_field(name: "spree_user[last_name]").set 'test_last_name'
    @browser.text_field(name: "spree_user[password]").set 'test123'
    @browser.text_field(name: "spree_user[password_confirmation]").set 'test123'
    @browser.input(name: "commit").click
    assert(@browser.div(class: 'flash notice').present?)
  end

  def searching_for_dining_digital_login
    @browser.text_field(name: "keywords").set 'Dining with the Prophets'
    @browser.input(class: "btn btn-primary img-responsive js-search-button").click
    assert(@browser.h1(text: "Search results for 'Dining with the Prophets'").exists?)
    @browser.img(alt: "Dining with the Prophets").click
    assert_equal("#{@base_url}/p/dining-prophets-lion-house-92869?variant_id=2692-hardcover", @browser.url, "incorrect location")
    @browser.span(text: "eBook").click
    @browser.button(class: "btn btn-lg btn-primary btn-block btn-add-to-cart").click
    assert_equal("#{@base_url}/item_added", @browser.url, "incorrect location")
    go_to_cart
    @browser.a(class: "btn btn-primary btn-lg pull-right btn-checkout").click
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
    go_to_cart
    @browser.a(class: "btn btn-primary btn-lg pull-right btn-checkout").click
    assert_equal("#{@base_url}/checkout/registration", @browser.url, "incorrect location")
    @browser.a(text: "Create a new account").click
    assert_equal("#{@base_url}/signup", @browser.url, "incorrect location")
    @browser.text_field(name: "spree_user[email]").set ::Faker::Internet.email
    @browser.text_field(name: "spree_user[first_name]").set 'test_name'
    @browser.text_field(name: "spree_user[last_name]").set 'test_last_name'
    @browser.text_field(name: "spree_user[password]").set 'test123'
    @browser.text_field(name: "spree_user[password_confirmation]").set 'test123'
    @browser.input(name: "commit").click
    assert(@browser.div(class: 'flash notice').present?)
    go_to_cart
  end

  def searching_for_dining_with_more_amount_digital
    @browser.text_field(name: "keywords").set 'Dining with the Prophets'
    @browser.input(class: "btn btn-primary img-responsive js-search-button").click
    assert(@browser.h1(text: "Search results for 'Dining with the Prophets'").exists?)
    @browser.img(alt: "Dining with the Prophets").click
    assert_equal("#{@base_url}/p/dining-prophets-lion-house-92869?variant_id=2692-hardcover", @browser.url, "incorrect location")
    @browser.span(text: "eBook").click
    @browser.button(class: "btn btn-lg btn-primary btn-block btn-add-to-cart").click
    assert_equal("#{@base_url}/item_added", @browser.url, "incorrect location")
    
    @browser.text_field(name: "keywords").set 'The Romney Family Table'
    @browser.input(class: "btn btn-primary img-responsive js-search-button").click
    assert(@browser.h1(text: "Search results for 'The Romney Family Table'").exists?)
    @browser.img(alt: "The Romney Family Table").click
    @browser.span(text: "eBook").click
    assert_equal("#{@base_url}/p/romney-family-table-ann-89648?variant_id=7330-ebook", @browser.url, "incorrect location")
    @browser.button(class: "btn btn-lg btn-primary btn-block btn-add-to-cart").click
    assert_equal("#{@base_url}/item_added", @browser.url, "incorrect location")
  end

  def procced_to_checkout_login
    go_to_cart
    @browser.a(class: "btn btn-primary btn-lg pull-right btn-checkout").click
  end

  def procced_to_checkout
    go_to_cart
    @browser.a(class: "btn btn-primary btn-lg pull-right btn-checkout").click
    assert_equal("#{@base_url}/checkout/registration", @browser.url, "incorrect location")
    @browser.a(text: "Create a new account").click
    assert_equal("#{@base_url}/signup", @browser.url, "incorrect location")
    @browser.text_field(name: "spree_user[email]").set ::Faker::Internet.email
    @browser.text_field(name: "spree_user[first_name]").set  ::Faker::Name.first_name
    @browser.text_field(name: "spree_user[last_name]").set ::Faker::Name.last_name
    password = ::Faker::Number.number(5)
    @browser.text_field(name: "spree_user[password]").set password
    @browser.text_field(name: "spree_user[password_confirmation]").set password
    @browser.input(name: "commit").click
    assert(@browser.div(class: 'flash notice').present?)
    @browser.a(class: "btn btn-primary btn-lg pull-right btn-checkout").click
  end
  
  def searching_for_God_Remembered_Me_digital
    @browser.text_field(name: "keywords").set 'God Remembered Me'
    @browser.input(class: "btn btn-primary img-responsive js-search-button").click
    assert(@browser.h1(text: "Search results for 'God Remembered Me'").exists?)
    @browser.img(alt: "God Remembered Me").click
    assert_equal("#{@base_url}/p/god-remembered-me-joseph-banks-88389?variant_id=9017-ebook", @browser.url, "incorrect location")
    @browser.button(class: "btn btn-lg btn-primary btn-block btn-add-to-cart").click
    assert_equal("#{@base_url}/item_added", @browser.url, "incorrect location")
  end

  def searching_for_dining_with_more_amount
    @browser.text_field(name: "keywords").set 'Dining with the Prophets'
    @browser.input(class: "btn btn-primary img-responsive js-search-button").click
    assert(@browser.h1(text: "Search results for 'Dining with the Prophets'").exists?)
    @browser.img(alt: "Dining with the Prophets").click
    assert_equal("#{@base_url}/p/dining-prophets-lion-house-92869?variant_id=2692-hardcover", browser.url, "incorrect location")
    @browser.button(class: "btn btn-lg btn-primary btn-block btn-add-to-cart").click
    assert_equal("#{b@ase_url}/item_added", @browser.url, "incorrect location")
    
    @browser.text_field(name: "keywords").set 'The Romney Family Table'
    @browser.input(class: "btn btn-primary img-responsive js-search-button").click
    assert(@browser.h1(text: "Search results for 'The Romney Family Table'").exists?)
    @browser.img(alt: "The Romney Family Table").click
    assert_equal("#{@base_url}/p/romney-family-table-ann-89648?variant_id=6324-hardcover", @browser.url, "incorrect location")
    @browser.button(class: "btn btn-lg btn-primary btn-block btn-add-to-cart").click
    assert_equal("#{@base_url}/item_added", @browser.url, "incorrect location")
    go_to_cart
    @browser.a(class: "btn btn-primary btn-lg pull-right btn-checkout").click
    assert_equal("#{@base_url}/checkout/registration", @browser.url, "incorrect location")
    @browser.a(text: "Create a new account").click
    assert_equal("#{@base_url}/signup", @browser.url, "incorrect location")
    @browser.text_field(name: "spree_user[email]").set ::Faker::Internet.email
    @browser.text_field(name: "spree_user[first_name]").set ::Faker::Name.first_name
    @browser.text_field(name: "spree_user[last_name]").set ::Faker::Name.last_name
    password = ::Faker::Number.number(5)
    @browser.text_field(name: "spree_user[password]").set password
    @browser.text_field(name: "spree_user[password_confirmation]").set password
    @browser.input(name: "commit").click
    assert(@browser.div(class: 'flash notice').present?)
  end

  def searching_for_dining_and_digital
    @browser.text_field(name: "keywords").set 'Dining with the Prophets'
    @browser.input(class: "btn btn-primary img-responsive js-search-button").click
    assert(@browser.h1(text: "Search results for 'Dining with the Prophets'").exists?)
    @browser.img(alt: "Dining with the Prophets").click
    assert_equal("#{@base_url}/p/dining-prophets-lion-house-92869?variant_id=2692-hardcover", @browser.url, "incorrect location")
    @browser.span(text: "eBook").click
    @browser.button(class: "btn btn-lg btn-primary btn-block btn-add-to-cart").click
    assert_equal("#{@base_url}/item_added", @browser.url, "incorrect location")
    
    @browser.text_field(name: "keywords").set 'The Romney Family Table'
    @browser.input(class: "btn btn-primary img-responsive js-search-button").click
    assert(@browser.h1(text: "Search results for 'The Romney Family Table'").exists?)
    @browser.img(alt: "The Romney Family Table").click
    assert_equal("#{@base_url}/p/romney-family-table-ann-89648?variant_id=6324-hardcover", @browser.url, "incorrect location")
    @browser.button(class: "btn btn-lg btn-primary btn-block btn-add-to-cart").click
    assert_equal("#{@base_url}/item_added", @browser.url, "incorrect location")
  end

  def billing_address_form
    assert_equal("#{@base_url}/checkout/address", @browser.url, "incorrect location")
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
  end

  def delivery_options
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
    amount = get_new_gift_card_number(13.48)
    @browser.text_field(id: "gift_card_number_5").set amount
    @browser.button(class: "btn btn-primary js-apply-gift-card-btn").click
  end

  def and_gift_card_number_two
    @browser.div(text: "Apply a Deseret Book Gift Card").click
    sleep(1) #for_aniamtion
    amount = get_new_gift_card_number(16.50)
    @browser.text_field(id: "gift_card_number_5").set amount
    @browser.button(class: "btn btn-primary js-apply-gift-card-btn").click
    sleep(2)
  end

  def and_gift_card_number_three
    @browser.div(text: "Apply a Deseret Book Gift Card").click
    sleep(1) #for_aniamtion
    amount = get_new_gift_card_number(2.98)
    @browser.text_field(id: "gift_card_number_5").set amount
    @browser.button(class: "btn btn-primary js-apply-gift-card-btn").click
  end

  def and_gift_card_number_one
    @browser.div(text: "Apply a Deseret Book Gift Card").click
    sleep(1) #for_aniamtion
    amount = get_new_gift_card_number(29.98)
    @browser.text_field(id: "gift_card_number_5").set amount
    @browser.button(class: "btn btn-primary js-apply-gift-card-btn").click
  end

  def and_gift_card_less_amount
    @browser.div(text: "Apply a Deseret Book Gift Card").click
    sleep(1) #for_aniamtion
    amount = get_new_gift_card_number(10.50)
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
    @browser.goto  "#{@base_url}/cart"
    @browser.input(value: "Empty Cart").click
  end

  def logout
    @browser.goto  "#{@base_url}/logout"
  end

  def that_s_it
    puts @browser.title
    @browser.goto  "#{@base_url}/logout"
    @browser.quit
  end

  def go_to_cart
    @browser.a(text: "Cart").click
    assert_equal("#{@base_url}/cart", @browser.url, "incorrect location")
  end

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
    result = HTTParty.post("#{@base_url}/api/fake_gift_card/create",
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

  def order_log(field, value = nil)
    return unless defined?(@@orders) # don't log unless #start_new_order_log called
    return unless @@orders.last[:start] # can't add to order not started.
    return if @@orders.last[:finished] # can't add to order record once finished.
    values = {}

    # populate values hash
    if field.is_a?(Hash)
      field.each{|k,v| values[k] = v }
    else
      values[field.to_sym] = value
    end

    # store items in values hash in @@orders
    values.each do |k,v|
      if (existing_value = @@orders.last[k.to_sym])
        if existing_value.is_a? Array
          @@orders.last[k.to_sym] << v
        else
          # storing a duplicate key; turn this in to an array and store both
          @@orders.last[k.to_sym] = [existing_value, v]
        end
      else
        @@orders.last[k.to_sym] = v
      end
    end
  end
end
