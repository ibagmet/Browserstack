require 'rubygems'
require 'selenium-webdriver'
require 'test/unit'
require 'watir-webdriver'
require 'faker'

class AccountWithCasesBrCiTest < Test::Unit::TestCase
    include Selenium

  def setup
    caps = WebDriver::Remote::Capabilities.new
    caps['project'] = ENV['BS_AUTOMATE_PROJECT'] if ENV['BS_AUTOMATE_PROJECT']
    caps['build'] = ENV['BS_AUTOMATE_BUILD'] if ENV['BS_AUTOMATE_BUILD']
    caps['name'] = 'Test <<Account With Cases>>'
    caps['platform'] = ENV['SELENIUM_PLATFORM'] || 'ANY'
    caps['browser'] = ENV['SELENIUM_BROWSER'] || 'chrome'
    caps['browser_version'] = ENV['SELENIUM_VERSION'] if ENV['SELENIUM_VERSION']
    @browser = Watir::Browser.new(:remote,
    :url => "http://matthewredd:SPcNqvdg4Kd4qvjp294S@hub.browserstack.com/wd/hub",
    :desired_capabilities => caps)
    @base_url = 'https://deseretbook.net'
  end

  def test_login_top_link
    @browser.goto "#{@base_url}/signup"
    @browser.a(text: 'Login').click
    assert_equal("#{@base_url}/login", @browser.url, "incorrect location")
    assert(
    @browser.strong(text: 'Login as Existing Customer').exists?,
    'Expected to find <strong> tag with text "Login as Existing Customer" but did not.'
    )
    @browser.goto "#{@base_url}/logout"
    @browser.quit
  end

  def test_login_bottom_link
    @browser.goto "#{@base_url}/login"
    @browser.input(value: 'Login').click
    assert_equal("#{@base_url}/login", @browser.url, "incorrect location")
    assert(@browser.div(class: 'flash error').present?)
    assert(@browser.text =~ /Invalid email or password./)
    @browser.goto "#{@base_url}/logout"
    @browser.quit
  end 

  def test_new_account_link
    @browser.goto "#{@base_url}/login" 
    @browser.a(text: 'Create a new account').click
    assert_equal("#{@base_url}/signup", @browser.url, "incorrect location")
    assert(
    @browser.div(text: 'New Customer').exists?,
    'Expected to find <div> tag with text "New Customer" but did not.'
    )
    @browser.goto "#{@base_url}/logout"
    @browser.quit
  end 

  def test_fill_out_form
    @browser.goto "#{@base_url}/signup"
    @browser.text_field(name: "spree_user[email]").set ::Faker::Internet.email
    @browser.text_field(name: "spree_user[first_name]").set ::Faker::Name.first_name
    @browser.text_field(name: "spree_user[last_name]").set ::Faker::Name.last_name
    password = ::Faker::Number.number(5)
    @browser.text_field(name: "spree_user[password]").set password
    @browser.text_field(name: "spree_user[password_confirmation]").set password
    @browser.input(name: "commit").click
    assert(@browser.div(class: 'flash notice').present?)
    @browser.quit
  end

  def test_failure_cases_invaild_password
    @browser.goto "#{@base_url}/signup"
    @browser.text_field(name: "spree_user[email]").set ::Faker::Internet.email
    @browser.text_field(name: "spree_user[first_name]").set ::Faker::Name.first_name
    @browser.text_field(name: "spree_user[last_name]").set ::Faker::Name.last_name
    @browser.input(name: "commit").click
    assert_equal("#{@base_url}/signup", @browser.url, "incorrect location")
    assert(
    @browser.strong(text: '1 error prohibited this record from being saved').exists?,
    'Expected to find <strong> tag with text "1 error prohibited this record from being saved" but did not.'
    )
    @browser.quit
  end

  def test_failure_cases_invaild_email
    @browser.goto "#{@base_url}/signup"
    @browser.text_field(name: "spree_user[first_name]").set ::Faker::Name.first_name
    @browser.text_field(name: "spree_user[last_name]").set ::Faker::Name.last_name
    password = ::Faker::Number.number(5)
    @browser.text_field(name: "spree_user[password]").set password
    @browser.text_field(name: "spree_user[password_confirmation]").set password
    @browser.input(name: "commit").click
    assert_equal("#{@base_url}/signup", @browser.url, "incorrect location")
    assert(
    @browser.strong(text: '1 error prohibited this record from being saved').exists?,
    'Expected to find <strong> tag with text "1 error prohibited this record from being saved" but did not.'
    )
    @browser.quit
  end

  def test_failure_cases_password_fields_do_not_match
    @browser.goto "#{@base_url}/signup"
    @browser.text_field(name: "spree_user[email]").set ::Faker::Internet.email
    @browser.text_field(name: "spree_user[first_name]").set ::Faker::Name.first_name
    @browser.text_field(name: "spree_user[last_name]").set ::Faker::Name.last_name
    @browser.text_field(name: "spree_user[password]").set ::Faker::Number.number(5)
    @browser.text_field(name: "spree_user[password_confirmation]").set ::Faker::Number.number(5)
    @browser.input(name: "commit").click
    assert_equal("#{@base_url}/signup", @browser.url, "incorrect location")
    assert(
    @browser.strong(text: '1 error prohibited this record from being saved').exists?,
    'Expected to find <strong> tag with text "1 error prohibited this record from being saved" but did not.'
    )
    @browser.quit
  end
end
