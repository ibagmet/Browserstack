require 'rubygems'
require 'selenium-webdriver'
require 'test/unit'
require 'watir-webdriver'
require 'faker'


class PasswordChangeTestForBrowserstack < Test::Unit::TestCase
    include Selenium

def setup
    caps = WebDriver::Remote::Capabilities.new
    caps[:name] = 'Watir WebDriver'

    caps[:os] = 'Windows'
    caps[:browser] = 'firefox'
    caps[:browser_version] = '20'

    caps['browserstack.debug'] = 'true'
    caps['browserstack.local'] = 'true'
    caps['browserstack.localIdentifier'] = 'Test123'

    @browser = Watir::Browser.new(:remote,
    :url => "http://ibagmet1:6HbMB1CQ8mdmy1Ys7b9U@hub.browserstack.com/wd/hub",
    :desired_capabilities => caps)
end

def test_post
    base_url = 'https://deseretbook.net'
    @browser.goto  'https://deseretbook.net/signup'
    email_name = ::Faker::Internet.safe_email 
    @browser.text_field(name: "spree_user[email]").set email_name
    @browser.text_field(name: "spree_user[first_name]").set 'test_name'
    @browser.text_field(name: "spree_user[last_name]").set 'test_last_name'
    @browser.text_field(name: "spree_user[password]").set 'test123'
    @browser.text_field(name: "spree_user[password_confirmation]").set 'test123'
    @browser.input(name: "commit").click
    assert(@browser.div(class: 'flash notice').present?)
    @browser.goto  'https://deseretbook.net/logout'
    @browser.goto  'https://deseretbook.net/login'
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