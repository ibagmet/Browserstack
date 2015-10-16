require 'rubygems'
require 'selenium-webdriver'
require 'test/unit'
require 'watir-webdriver'
require 'faker'

class SampleTest < Test::Unit::TestCase
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
    @base_url = 'https://deseretbook.net'
  end

  def test_post
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




