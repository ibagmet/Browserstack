require 'rubygems'
require 'selenium-webdriver'
require 'test/unit'
require 'watir-webdriver'
require 'faker'

class WishListBsCiTest < Test::Unit::TestCase
    include Selenium

  def setup
    caps = WebDriver::Remote::Capabilities.new
    caps['project'] = ENV['BS_AUTOMATE_PROJECT'] if ENV['BS_AUTOMATE_PROJECT']
    caps['build'] = ENV['BS_AUTOMATE_BUILD'] if ENV['BS_AUTOMATE_BUILD']
    caps['name'] = 'Test <<Wish List>>'
    caps['platform'] = ENV['SELENIUM_PLATFORM'] || 'ANY'
    caps['browser'] = ENV['SELENIUM_BROWSER'] || 'chrome'
    caps['browser_version'] = ENV['SELENIUM_VERSION'] if ENV['SELENIUM_VERSION']

    @browser = Watir::Browser.new(:remote,
    :url => "http://matthewredd:SPcNqvdg4Kd4qvjp294S@hub.browserstack.com/wd/hub",
    :desired_capabilities => caps)
  end

  def test_whish_lists
    base_url = 'https://deseretbook.net'
    @browser.goto  "#{base_url}/signup"
    @browser.text_field(name: "spree_user[email]").set ::Faker::Internet.email
    @browser.text_field(name: "spree_user[first_name]").set ::Faker::Name.first_name
    @browser.text_field(name: "spree_user[last_name]").set ::Faker::Name.last_name
    password = ::Faker::Number.number(5)
    @browser.text_field(name: "spree_user[password]").set password
    @browser.text_field(name: "spree_user[password_confirmation]").set password
    @browser.input(name: "commit").click
    assert(@browser.div(class: 'flash notice').present?)
    go_to_my_account
    @browser.a(text: "Create new wishlist").click
    assert_equal("#{base_url}/wishlists/new", @browser.url, "incorrect location")
    @browser.text_field(name: "wishlist[name]").set 'i have the need the need for speed'
    @browser.input(name: "commit").click
    go_to_my_account
    assert @browser.text.include?("i have the need the need for speed")
    searching_for_bible
    go_to_my_account
    @browser.a(text: "i have the need the need for speed").exists?
    @browser.a(text: "i have the need the need for speed").click
    assert @browser.text.include?("Black Unindexed Regular Economy Bible: 2013 Edition")
    @browser.a(text: "Edit wishlist").click
    assert @browser.text.include?("Editing wishlist")
    @browser.a(text: "Delete wishlist").click
    @browser.a(text: "OK").click
    @browser.goto "#{@base_url}/logout"
  end

  def test_whishlist_as_a_guest
    @browser.goto  "https://deseretbook.net"
    @browser.a(text: "Wish List").click
    assert_equal("https://deseretbook.net/wishlists", @browser.url, "incorrect location")
    assert @browser.text.include?("Wishlists")
  end

private

  def searching_for_bible
    base_url = 'https://deseretbook.net'
    @browser.text_field(name: "keywords").set 'Black Unindexed Regular Economy Bible: 2013 Edition'
    @browser.input(class: "btn btn-primary img-responsive js-search-button").click
    assert(@browser.h1(text: "Search results for 'Black Unindexed Regular Economy Bible: 2013 Edition'").exists?)
    @browser.a(text: "Learn More").click
    assert_equal("#{@base_url}/p/black-unindexed-regular-economy-bible-2013-edition-lds-distribution-center-92289?variant_id=3646-hardcover", @browser.url, "incorrect location")
    @browser.button(class: "btn btn-lg btn-block btn-outline btn-add-to-wishlist").click
  end

  def go_to_my_account
    base_url = 'https://deseretbook.net'
    @browser.a(text: "My Account").when_present.click
    assert_equal("#{base_url}/account", @browser.url, "incorrect location")
    assert @browser.text.include?("My Account")
    @browser.a(text: "My Wishlists").click
  end
end

