require 'rubygems'
require 'selenium-webdriver'
require 'test/unit'
require 'watir-webdriver'
require 'faker'

class PasswordChangeBrCiTest < Test::Unit::TestCase
    include Selenium

  def setup
    caps = WebDriver::Remote::Capabilities.new
    caps['project'] = ENV['BS_AUTOMATE_PROJECT'] if ENV['BS_AUTOMATE_PROJECT']
    caps['build'] = ENV['BS_AUTOMATE_BUILD'] if ENV['BS_AUTOMATE_BUILD']
    caps['name'] = 'Test <<Changing Password>>'
    caps['platform'] = ENV['SELENIUM_PLATFORM'] || 'ANY'
    caps['browser'] = ENV['SELENIUM_BROWSER'] || 'chrome'
    caps['browser_version'] = ENV['SELENIUM_VERSION'] if ENV['SELENIUM_VERSION']

    @browser = Watir::Browser.new(:remote,
    :url => "http://matthewredd:SPcNqvdg4Kd4qvjp294S@hub.browserstack.com/wd/hub",
    :desired_capabilities => caps)
  end

  def test_post
    base_url = 'https://deseretbook.net'
    @browser.goto  "#{base_url}/signup"
    email_name = ::Faker::Internet.safe_email 
    @browser.text_field(name: "spree_user[email]").set email_name
    @browser.text_field(name: "spree_user[first_name]").set 'test_name'
    @browser.text_field(name: "spree_user[last_name]").set 'test_last_name'
    @browser.text_field(name: "spree_user[password]").set 'test123'
    @browser.text_field(name: "spree_user[password_confirmation]").set 'test123'
    @browser.input(name: "commit").click
    assert(@browser.div(class: 'flash notice').present?)
    @browser.goto  "#{base_url}/logout"
    @browser.goto  "#{base_url}/login"
    @browser.text_field(name: "spree_user[email]").set email_name
    @browser.text_field(name: "spree_user[password]").set 'test123'
    @browser.input(name: "commit").click
    @browser.a(text: "My Account").click
    assert_equal("#{base_url}/account", @browser.url, "incorrect location")
    assert @browser.text.include?("My Account")
    @browser.a(text: "Edit").click
    @browser.text_field(name: "user[password]").set "test321"
    @browser.text_field(name: "user[password_confirmation]").set "test321"
    @browser.input(name: "commit").click
    assert_equal("#{base_url}/login", @browser.url, "incorrect location")
    assert(@browser.div(class: 'flash notice').present?)
    @browser.text_field(name: "spree_user[email]").set email_name
    @browser.text_field(name: "spree_user[password]").set 'test321'
    @browser.input(name: "commit").click
    assert(@browser.div(class: 'flash success').present?)
    puts @browser.title
    @browser.quit
    end
end