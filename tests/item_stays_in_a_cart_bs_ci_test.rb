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
    caps['name'] = 'Watir WebDriver'
    caps['platform'] = ENV['SELENIUM_PLATFORM'] || 'ANY'
    caps['browser'] = ENV['SELENIUM_BROWSER'] || 'chrome'
    caps['browser_version'] = ENV['SELENIUM_VERSION'] if ENV['SELENIUM_VERSION']

    @browser = Watir::Browser.new(:remote,
    :url => "http://ibagmet1:6HbMB1CQ8mdmy1Ys7b9U@hub.browserstack.com/wd/hub",
    :desired_capabilities => caps)
  end

  def test_post
    @base_url = 'https://stage.deseretbook.net'
    @browser.goto  "#{@base_url}/signup"
    email_name = ::Faker::Internet.safe_email 
    @browser.text_field(name: "spree_user[email]").set email_name
    @browser.text_field(name: "spree_user[first_name]").set 'test_name'
    @browser.text_field(name: "spree_user[last_name]").set 'test_last_name'
    @browser.text_field(name: "spree_user[password]").set 'test123'
    @browser.text_field(name: "spree_user[password_confirmation]").set 'test123'
    @browser.input(name: "commit").click
    assert(@browser.div(class: 'flash notice').present?)
    searching_for_jingles
    @browser.goto  "#{base_url}/logout"
    @browser.goto  "#{base_url}/login"
    @browser.text_field(name: "spree_user[email]").set email_name
    @browser.text_field(name: "spree_user[password]").set 'test123'
    @browser.input(name: "commit").click
    @browser.goto  "#{base_url}/cart"
    @browser.a(text: "Jingles 3").exists?
    @browser.close
    @browser = open_browser
    @browser.goto  "#{base_url}/login"
    @browser.text_field(name: "spree_user[email]").set email_name
    @browser.text_field(name: "spree_user[password]").set 'test123'
    @browser.input(name: "commit").click
    @browser.goto  "#{base_url}/cart"
    @browser.a(text: "Jingles 3").exists?
    puts @browser.title
    @browser.quit
  end

private

  def searching_for_jingles
    @browser.text_field(name: "keywords").set 'Jingles 3'
    @browser.input(class: "btn btn-primary img-responsive js-search-button").click
    assert(@browser.h1(text: "Search results for 'Jingles 3'").exists?)
    @browser.a(text: "Learn More").click
    assert_equal("#{@base_url}/p/jingles-3-voice-male-86135?variant_id=10175-cd", @browser.url, "incorrect location")
    @browser.button(class: "btn btn-lg btn-primary btn-block btn-add-to-cart").exists?
    @browser.button(class: "btn btn-lg btn-primary btn-block btn-add-to-cart").click
    assert_equal("#{@base_url}/item_added", @browser.url, "incorrect location")
  end
end