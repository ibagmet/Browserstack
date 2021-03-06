require 'rubygems'
require 'selenium-webdriver'
require 'test/unit'
require 'watir-webdriver'
require 'faker'

class SetupBsCiTest < Test::Unit::TestCase
    include Selenium

  def setup
    caps = WebDriver::Remote::Capabilities.new
    caps['name'] = 'Test <<Setup>>'
    caps['project'] = ENV['BS_AUTOMATE_PROJECT'] if ENV['BS_AUTOMATE_PROJECT']
    caps['build'] = ENV['BS_AUTOMATE_BUILD'] if ENV['BS_AUTOMATE_BUILD']

    if ENV['BS_AUTOMATE_OS']
    caps['os'] = ENV['BS_AUTOMATE_OS']
    caps['os_version'] = ENV['BS_AUTOMATE_OS_VERSION']
    else
    caps['platform'] = ENV['SELENIUM_PLATFORM'] || 'ANY'
    end

    caps['browser'] = ENV['SELENIUM_BROWSER'] || 'chrome'
    caps['browser_version'] = ENV['SELENIUM_VERSION'] if ENV['SELENIUM_VERSION']

    @browser = Watir::Browser.new(:remote,
    :url => "http://matthewredd:SPcNqvdg4Kd4qvjp294S@hub.browserstack.com/wd/hub",
    :desired_capabilities => caps)
  end

  def test_post
    base_url = 'https://deseretbook.net'
    @browser.goto base_url
    @browser.link(text: "Login").when_present.click
    @browser.link(text: "Create a new account").click
    @browser.text_field(name: "spree_user[email]").set ::Faker::Internet.email
    @browser.text_field(name: "spree_user[first_name]").set ::Faker::Name.first_name
    @browser.text_field(name: "spree_user[last_name]").set ::Faker::Name.last_name
    password = ::Faker::Number.number(5)
    @browser.text_field(name: "spree_user[password]").set password
    @browser.text_field(name: "spree_user[password_confirmation]").set password
    @browser.form(id: "new_spree_user").when_present.submit
    @browser.link(text: "My Account").when_present.click
    @browser.link(text: "Addresses").when_present.click
    sleep(1) #animation
    @browser.a(text: "Add new address").click
    assert_equal("#{base_url}/addresses/new", @browser.url, "incorrect location")
    @browser.text_field(name: "address[firstname]").set 'test'
    @browser.text_field(name: "address[lastname]").set 'user'
    @browser.text_field(name: "address[address1]").set '1445 K St'
    @browser.text_field(name: "address[city]").set 'Lincoln'
    @browser.select_list(name: "address[state_id]").select 'Nebraska'
    @browser.text_field(name: "address[zipcode]").set '68508'
    @browser.text_field(name: "address[phone]").set '555-5555'
    @browser.input(name: "commit").when_present.click
    assert @browser.text.include?('Address has been successfully created!'), "Address was not successfully created."
    @browser.link(text: "Addresses").when_present.click
    assert @browser.text.include?('test'), "user name not on page"
    assert @browser.text.include?('1445 K St'), "street address not on page"
    assert @browser.text.include?('Lincoln NE 68508'), "city/state/zip not on page"
    assert @browser.text.include?('United States'), "country not on page"
    puts @browser.title
    @browser.quit
  end
end
