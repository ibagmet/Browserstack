require 'httparty'
require 'ruby-progressbar'
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
    caps['name'] = 'Test <<Home Page>>'
    caps['platform'] = ENV['SELENIUM_PLATFORM'] || 'ANY'
    caps['browser'] = ENV['SELENIUM_BROWSER'] || 'chrome'
    caps['browser_version'] = ENV['SELENIUM_VERSION'] if ENV['SELENIUM_VERSION']

    @browser = Watir::Browser.new(:remote,
    :url => "http://matthewredd:SPcNqvdg4Kd4qvjp294S@hub.browserstack.com/wd/hub",
    :desired_capabilities => caps)
  end

  def test_all_links_return_200
    @browser.goto  "#{base_url}"
    anchors = @browser.driver.find_elements(tag_name: 'a').select(&:displayed?).select do |anchor|
      href = anchor.attribute('href').to_s

      case href
      when ''
        # empty target, probably ajax. Don't follow this.
        false
      when @base_url, "#{@base_url}/"
        # Home page link, assumed to work because that's where we are.
        # No need to test this.
        false
      when /\#$/
        # Probably an ajax call, Don't follow these.
        false
      when /^(?!http)/
        # Ignore links that aren't http or https.
        false
      else
        # Follow all others
        true
      end
    end

    failures = []

    progressbar = new_progressbar('Checking URLs', anchors.length)

    anchors.each_with_index do |anchor, i|
      url = anchor.attribute('href')
      text = anchor.text.inspect
      # puts "Checking link #{i+1}/#{anchors.size}: #{text} (#{url.inspect})"

      failures << anchor unless valid_link?(url)

      progressbar.increment
    end

    assert(failures.empty?,
      [
        'The following links did not returns a 200:',
        failures.map{|anchor|
          "Text: #{anchor.text.inspect}, URL: #{anchor.attribute('href').inspect}"
        }.join("\n")
      ].join("\n"),
      debug_on_failure: false
    )

  end

  # Go through all the links in the drop-down menus of the home page header and
  # make sure they all go to a page that returns 200 OK.
  def test_all_header_menu_links_return_200
    @browser.goto  "#{base_url}"

    failures = []

    @browser.ul(class: 'nav-links').lis.each do |menu_li|
      # Brittle way to find just the top-level menu <li>s
      next unless menu_li.attribute_value('data-url')

      menu_name = menu_li.text

      # There may be a hidden <div> in the <li>, or just a link.
      # If it's just a link, record the anchor and continue.
      if !menu_li.div.exists? && menu_li.a.exists?
        url = menu_li.a.attribute_value('href')
        puts "Menu link: #{menu_name.inspect}: #{url.inspect}"
        failures << [menu_name, url] unless valid_link?(url)
        next
      end

      # Before mouse-over, verify the div is hidden.
      assert(!menu_li.div.visible?)

      # Mouse-over the li
      menu_li.hover

      # Verify the div is now visible
      assert(menu_li.div.visible?)

      # Get the links in the menu
      menu_anchors = menu_li.div.as.to_a

      # Verify there are links; this is an easy way to test that we got the
      # right element.
      assert(
        !menu_anchors.empty?,
        "Didn't find any links in menu #{menu_name.inspect}. Did the menu open?"
      )

      progressbar = new_progressbar("Links in #{menu_name.inspect}", menu_anchors.length)

      menu_anchors.each do |anchor|
        url = anchor.attribute_value('href')
        text = anchor.text
        # puts "Checking link #{text.inspect} (#{url.inspect})"
        failures << [menu_name, url, text] unless valid_link?(url)
        progressbar.increment
      end
    end

    assert(failures.empty?,
      [
        'The following links did not returns a 200:',
        failures.map{|menu, url, text|
          "Menu: #{menu.inspect}, Text: #{text.inspect}, URL: #{url.inspect}"
        }.join("\n")
      ].join("\n"),
      debug_on_failure: false
    )

  end

private

  # Argument is URL as a string.
  # Returns true if url returns a 200 OK. False if otherwise.
  def valid_link?(url)
    # GET or HEAD? Head is more friendly to the server, but some pages
    # May behave differently depending on HEAD or GET.
    HTTParty.head(url,
      verify: false, # don't verify ssl certs
    ).code == 200
  end

  def new_progressbar(title, total, options={})
    ProgressBar.create(
      {
        title: title,
        total: total,
        format: "%t: |%B| %p%% (%c/%C) %e"
      }.merge(options)
    )
  end
end