require 'rubygems'
require 'selenium-webdriver'
require 'test/unit'
require 'watir-webdriver'
require 'faker'

class ItemAddedBsCiTest < Test::Unit::TestCase
    include Selenium

  def setup
    caps = WebDriver::Remote::Capabilities.new
    caps['project'] = ENV['BS_AUTOMATE_PROJECT'] if ENV['BS_AUTOMATE_PROJECT']
    caps['build'] = ENV['BS_AUTOMATE_BUILD'] if ENV['BS_AUTOMATE_BUILD']
    caps['name'] = 'Test <<Item Added>>'
    caps['platform'] = ENV['SELENIUM_PLATFORM'] || 'ANY'
    caps['browser'] = ENV['SELENIUM_BROWSER'] || 'chrome'
    caps['browser_version'] = ENV['SELENIUM_VERSION'] if ENV['SELENIUM_VERSION']

    @browser = Watir::Browser.new(:remote,
    :url => "http://matthewredd:SPcNqvdg4Kd4qvjp294S@hub.browserstack.com/wd/hub",
    :desired_capabilities => caps)
  end

  def test_item_in_cart
    base_url = 'https://deseretbook.net'
    @browser.goto "#{base_url}/signup"
    @browser.text_field(name: "spree_user[email]").set ::Faker::Internet.email
    @browser.text_field(name: "spree_user[first_name]").set ::Faker::Name.first_name
    @browser.text_field(name: "spree_user[last_name]").set ::Faker::Name.last_name
    @browser.text_field(name: "spree_user[password]").set 'test123'
    @browser.text_field(name: "spree_user[password_confirmation]").set 'test123'
    @browser.input(name: "commit").click
    assert(@browser.div(class: 'flash notice').present?)
    @browser.goto "#{base_url}/cart"
    @browser.a(text: "Continue shopping").exists?
    @browser.a(text: "Continue shopping").click
    assert_equal("#{base_url}/products?sort=popular", @browser.url, "incorrect location")
    @browser.text_field(name: "keywords").set 'Marble Christus Statue'
    @browser.input(class: "btn btn-primary img-responsive js-search-button").click
    assert(@browser.h1(text: "Search results for 'Marble Christus Statue'").exists?)
    @browser.a(text: "19 inch").click
    assert_equal("#{base_url}/p/marble-christus-statue-deseret-book-company-41038?variant_id=62304-19-inch", @browser.url, "incorrect location")
    @browser.button(text: "Add To Cart").click
    assert_equal("#{base_url}/item_added", @browser.url, "incorrect location")
    
    @browser.goto 'http://the-internet.herokuapp.com'
    @browser.link(:text, 'A/B Testing').click(:command, :shift)
    @browser.windows.last.use

    @browser.goto "#{base_url}/logout"
    @browser.goto "#{base_url}/login"
    @browser.text_field(name: "spree_user[email]").set email_new
    @browser.text_field(name: "spree_user[password]").set 'test123'
    @browser.input(name: "commit").click
    @browser.goto 'http://deseretbook.net/cart' 
    assert(@browser.a(text: "Marble Christus Statue").exists?)
    
    @browser.goto 'http://the-internet.herokuapp.com'
    @browser.link(:text, 'A/B Testing').click(:command, :shift)
    @browser.windows.last.use

    @browser.goto "#{base_url}/cart"
    assert(@browser.a(text: "Marble Christus Statue").exists?)
    @browser.close
  end
end
