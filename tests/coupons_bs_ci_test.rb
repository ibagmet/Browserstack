require 'rubygems'
require 'selenium-webdriver'
require 'test/unit'
require 'watir-webdriver'
require 'faker'
require 'httparty'
require 'json'

class WriteAReviewTestForBrowserstack < Test::Unit::TestCase
    include Selenium

  def setup
    caps = WebDriver::Remote::Capabilities.new
    caps['project'] = ENV['BS_AUTOMATE_PROJECT'] if ENV['BS_AUTOMATE_PROJECT']
    caps['build'] = ENV['BS_AUTOMATE_BUILD'] if ENV['BS_AUTOMATE_BUILD']
    caps['name'] = 'Test <<-Coupons->>'
    caps['platform'] = ENV['SELENIUM_PLATFORM'] || 'ANY'
    caps['browser'] = ENV['SELENIUM_BROWSER'] || 'chrome'
    caps['browser_version'] = ENV['SELENIUM_VERSION'] if ENV['SELENIUM_VERSION']

    @browser = Watir::Browser.new(:remote,
    :url => "http://matthewredd:SPcNqvdg4Kd4qvjp294S@hub.browserstack.com/wd/hub",
    :desired_capabilities => caps)
  end

  def test_coupons_cases
    base_url = 'https://deseretbook.net'
    @browser.goto  "#{base_url}/login"
    @browser.text_field(name: "spree_user[email]").set 'ibagmet@deseretbook.com'
    @browser.text_field(name: "spree_user[password]").set 'test123'
    @browser.input(name: "commit").click
    assert_equal(@browser.div(class: 'flash success').text, "Logged in successfully")
    @browser.goto  "#{base_url}/cart"
    @browser.input(class: "btn btn-sm btn-link-plain").click
    @browser.text_field(name: "keywords").set 'The Book of Mormon for Latter-day Saint Families'
    @browser.input(class: "btn btn-primary img-responsive js-search-button").click
    assert(@browser.h1(text: "Search results for 'The Book of Mormon for Latter-day Saint Families'").exists?)
    @browser.a(text: "Hardcover").click
    @browser.button(class: "btn btn-lg btn-primary btn-block btn-add-to-cart").click
    assert_equal("#{base_url}/item_added", @browser.url, "incorrect location")
    go_to_cart
    assert_equal("#{base_url}/cart", @browser.url, "incorrect location")
    #browser.a(text: "Close").click
    @browser.a(class: "btn btn-primary btn-lg pull-right btn-checkout").when_present.click
    assert_equal("#{base_url}/checkout/address", @browser.url, "incorrect location")
    @browser.button(class: "btn btn-primary pull-right js-form-validate btn-continue").when_present.click
    assert_equal("#{base_url}/checkout/delivery", @browser.url, "incorrect location")
    @browser.button(class: "btn btn-primary pull-right btn-continue").when_present.click
    assert_equal("#{base_url}/checkout/payment", @browser.url, "incorrect location")

    @browser.a(text: "Enter coupon code").when_present.click
    sleep(1) #animation
    @browser.text_field(name: "coupon_code").set 'test123_50'
    @browser.button(text: "Apply Coupon Code").click
    @browser.div(text: "The coupon code was successfully applied to your order.").exists?
    
    @browser.a(text: "Enter coupon code").when_present.click
    sleep(1) #animation
    @browser.text_field(name: "coupon_code").set 'test123_one_more'
    @browser.button(text: "Apply Coupon Code").click
    @browser.div(text: "The coupon code was successfully applied to your order.").exists?
    
    @browser.a(text: "Enter coupon code").when_present.click
    sleep(1) #animation
    @browser.text_field(name: "coupon_code").set 'smth_strange'
    @browser.button(text: "Apply Coupon Code").when_present.click
    @browser.div(text: "The coupon code you entered doesn't exist. Please try again.").exists?

    @browser.text_field(name: "coupon_code").set 'test123_expired'
    @browser.button(text: "Apply Coupon Code").when_present.click
    @browser.div(text: "The coupon code is expired").exists?

    @browser.text_field(name: "coupon_code").set 'test_only_for_cristmas'
    @browser.button(text: "Apply Coupon Code").when_present.click
    @browser.div(text: "This coupon code could not be applied to the cart at this time.").exists?
    sleep(1)
    @browser.text_field(name: "coupon_code").set 'test123_50'
    @browser.button(text: "Apply Coupon Code").when_present.click
    @browser.div(text: "The coupon code has already been applied to this order").exists?

    @browser.button(class: "btn btn-primary pull-right btn-continue js-submit-btn").when_present.click
    assert_equal("#{base_url}/checkout/confirm", @browser.url, "incorrect location")
    @browser.button(class: "btn btn-primary btn-lg pull-right btn-continue").when_present.click
    assert_equal(@browser.div(class: 'flash notice').text, "Thank You. We have successfully received your order.")
    @browser.goto "#{base_url}/logout"
    @browser.quit
  end

  private

  def go_to_cart
    @browser.a(text: "Cart").click
    assert_equal("#{@base_url}/cart", @browser.url, "incorrect location")
  end
end