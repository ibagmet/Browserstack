require 'rubygems'
require 'selenium-webdriver'
require 'test/unit'
require 'watir-webdriver'
require 'faker'

class ItemStaysInACartBrCiTest < Test::Unit::TestCase
    include Selenium

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

  def test_address_default
    @browser.goto "#{@base_url}/signup"
    email_new = ::Faker::Internet.safe_email
    @browser.text_field(name: "spree_user[email]").set email_new
    @browser.text_field(name: "spree_user[first_name]").set ::Faker::Name.first_name
    @browser.text_field(name: "spree_user[last_name]").set ::Faker::Name.last_name
    @browser.text_field(name: "spree_user[password]").set 'test123'
    @browser.text_field(name: "spree_user[password_confirmation]").set 'test123'
    @browser.input(name: "commit").click
    assert(@browser.div(class: 'flash notice').present?)
    @browser.goto "#{@base_url}/account"
    click_address_link    
    click_new_address
    fill_out_form
    @browser.text_field(name:"address[zipcode]").set ::Faker::Address.zip_code
    @browser.input(name:"default_bill").click
    check_filled_form
    click_new_address
    fill_out_form
    @browser.text_field(name:"address[zipcode]").set '77889'
    check_filled_form
    click_address_link
    search_for_statue
    #browser.a(text: "Close").click
    changing_address
    billing_address
    confirmation_button
    confirmation_button
    assert_equal("#{@base_url}/checkout/delivery", @browser.url, "incorrect location")
    @browser.span(text: "$71.90").click
    @browser.button(class: 'btn btn-primary pull-right btn-continue').click
    assert_equal("#{@base_url}/checkout/payment", @browser.url, "incorrect location")
    @browser.text_field(id: "name_on_card_2").set 'test user'
    @browser.text_field(id: "card_number").set '4111111111111111'
    @browser.text_field(id: "card_code").set '555'
    @browser.select(id: "date_month").select '1 - January'
    @browser.select(id: "date_year").select '2018'
    finishing_part
    search_for_statue
    changing_address
    billing_address
    @browser.input(id: "order_ship_address_id_0").click
    @browser.text_field(name:"order[ship_address_attributes][firstname]").set ::Faker::Name.first_name 
    @browser.text_field(name:"order[ship_address_attributes][lastname]").set ::Faker::Name.last_name 
    @browser.text_field(name:"order[ship_address_attributes][address1]").set ::Faker::Address.street_address
    @browser.text_field(name:"order[ship_address_attributes][address2]").set ::Faker::Address.secondary_address
    @browser.text_field(name:"order[ship_address_attributes][zipcode]").set ::Faker::Address.zip_code
    @browser.text_field(name:"order[ship_address_attributes][city]").set ::Faker::Address.city
    @browser.select(name:"order[ship_address_attributes][state_id]").select 'Colorado'
    @browser.text_field(name:"order[ship_address_attributes][phone]").set ::Faker::PhoneNumber.cell_phone
    confirmation_button
    confirmation_button
    assert_equal("#{base_url}/checkout/delivery", @browser.url, "incorrect location")
    @browser.span(text: "$49.90").click
    @browser.button(class: "btn btn-primary pull-right btn-continue").click
    assert_equal("#{@base_url}/checkout/payment", @browser.url, "incorrect location")
    finishing_part
    puts @browser.title
    @browser.quit
  end

private

  def click_address_link
    @browser.a(text: "Addresses").click
    assert(
    @browser.h3(text: 'Saved Addresses').exists?,
    'Expected to find <h3> tag with text "Saved Addresses" but did not.')
  end

  def click_new_address
    @browser.goto "#{@base_url}/addresses/new"
    assert_equal("#{@base_url}/addresses/new", @browser.url, "incorrect location")
  end
     
  def fill_out_form
    @browser.text_field(name:"address[firstname]").set ::Faker::Name.first_name 
    @browser.text_field(name:"address[lastname]").set ::Faker::Name.last_name 
    @browser.text_field(name:"address[address1]").set ::Faker::Address.street_address
    @browser.text_field(name:"address[address2]").set ::Faker::Address.secondary_address
    @browser.text_field(name:"address[city]").set ::Faker::Address.city
    @browser.select(name:"address[state_id]").select 'New York'
    @browser.text_field(name:"address[phone]").set ::Faker::PhoneNumber.cell_phone
  end

  def check_filled_form
    @browser.input(name:"commit").click
    assert_equal(@browser.div(class: 'flash notice').text, "Address has been successfully created!")
  end

  def back_to_change_address_type
    @browser.goto "#{@base_url}/Cart"
    @browser.a(class: "btn btn-primary btn-lg pull-right btn-checkout")
  end

  def billing_address
    @browser.input(name: "order[use_billing]").click
  end

  def search_for_statue
    @browser.text_field(name: "keywords").set 'Marble Christus Statue'
    @browser.input(class: "btn btn-primary img-responsive js-search-button").click
    assert(@browser.h1(text: "Search results for 'Marble Christus Statue'").exists?)
    @browser.a(text: "19 inch").click
    assert_equal("#{@base_url}/p/marble-christus-statue-deseret-book-company-41038?variant_id=62304-19-inch", @browser.url, "incorrect location")
    @browser.button(text: "Add To Cart").click
    assert_equal("#{@base_url}/item_added", @browser.url, "incorrect location")
    @browser.a(text: "Cart").click
    assert_equal("#{@base_url}/cart", @browser.url, "incorrect location")
  end

  def changing_address
    @browser.a(class: "btn btn-primary btn-lg pull-right btn-checkout").click
    assert_equal("#{@base_url}/checkout/address", @browser.url, "incorrect location")
  end

  def finishing_part
    @browser.button(class: "btn btn-primary pull-right btn-continue js-submit-btn").click
    assert_equal("#{@base_url}/checkout/confirm", @browser.url, "incorrect location")
    @browser.button(class: "btn btn-primary btn-lg pull-right btn-continue").click
    assert_equal(@browser.div(class: 'flash notice').text, "Thank You. We have successfully received your order.")
  end

  def confirmation_button
    @browser.button(class: "btn btn-primary pull-right js-form-validate btn-continue").click
  end
end
