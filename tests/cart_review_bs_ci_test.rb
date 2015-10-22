require 'rubygems'
require 'selenium-webdriver'
require 'test/unit'
require 'watir-webdriver'
require 'faker'


class CartReviewBrCiTest < Test::Unit::TestCase
    include Selenium

  def setup
    caps = WebDriver::Remote::Capabilities.new
    caps['project'] = ENV['BS_AUTOMATE_PROJECT'] if ENV['BS_AUTOMATE_PROJECT']
    caps['build'] = ENV['BS_AUTOMATE_BUILD'] if ENV['BS_AUTOMATE_BUILD']
    caps['name'] = 'Test <<Cart Review>>'
    caps['platform'] = ENV['SELENIUM_PLATFORM'] || 'ANY'
    caps['browser'] = ENV['SELENIUM_BROWSER'] || 'chrome'
    caps['browser_version'] = ENV['SELENIUM_VERSION'] if ENV['SELENIUM_VERSION']

    @browser = Watir::Browser.new(:remote,
    :url => "http://matthewredd:SPcNqvdg4Kd4qvjp294S@hub.browserstack.com/wd/hub",
    :desired_capabilities => caps)
  end

  def test_add_twice_to_cart
    empty_cart
    add_physical_item_to_cart(quantity: 2)
    goto  '/cart'
    
    quantity = browser.text_field(class: 'line_item_quantity').value.to_i
    cart_item_price = browser.td(class: 'cart-item-price').text.split("\n").first.gsub(/[^0-9\.]/, '').to_f
    cart_item_total = browser.td(class: 'cart-item-total').text.split("\n").first.gsub(/[^0-9\.]/, '').to_f

    assert(quantity == 2)
    assert((cart_item_price * quantity) == cart_item_total)
    browser.text_field(class: 'line_item_quantity').set(1)

    wait = 5
    while (wait >= 0) do
        if browser.td(class: 'cart-item-total').value == cart_item_total
            break
        end
        sleep(1) #animation
        wait = wait - 1
    end

    quantity = browser.text_field(class: 'line_item_quantity').value.to_i
    cart_item_price = browser.td(class: 'cart-item-price').text.split("\n").first.gsub(/[^0-9\.]/, '').to_f
    cart_item_total = browser.td(class: 'cart-item-total').text.split("\n").first.gsub(/[^0-9\.]/, '').to_f

    assert(quantity == 1)
    assert(cart_item_price * quantity == cart_item_total)
  end
     
   def test_remove_item_from_card
    add_physical_item_to_cart(quantity: 1)
    goto  '/cart'   
    browser.a(text: 'Remove').click
    assert(
        browser.p(text: 'Your cart is empty').exists?,
        'Expected to find <P> tag with text "Your cart is empty" but did not.'
    )
  end

  def test_empty_cart_link
    add_physical_item_to_cart(quantity: 1)
    goto  '/cart'   
    browser.input(value: 'Empty Cart').click
    assert(
        browser.p(text: 'Your cart is empty').exists?,
        'Expected to find <P> tag with text "Your cart is empty" but did not.'
    )
  end

end
