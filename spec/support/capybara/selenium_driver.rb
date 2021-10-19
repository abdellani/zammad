# Copyright (C) 2012-2021 Zammad Foundation, http://zammad-foundation.org/

# This file registers the custom Zammad chrome and firefox drivers.
# The options check if a REMOTE_URL ENV is given and change the
# configurations accordingly.

Capybara.register_driver(:zammad_chrome) do |app|

  # Turn on browser logs
  options = Selenium::WebDriver::Chrome::Options.new(
    logging_prefs: {
      browser: 'ALL'
    },
    prefs:         {
      'intl.accept_languages'                                => 'en-US',
      'profile.default_content_setting_values.notifications' => 1, # ALLOW notifications
    },
  )

  options = {
    browser: :chrome,
    options: options
  }

  if ENV['REMOTE_URL'].present?
    options[:browser] = :remote
    options[:url]     = ENV['REMOTE_URL']
  end

  Capybara::Selenium::Driver.new(app, **options).tap do |driver|
    # Selenium 4 installs a default file_detector which finds wrong files/directories such as zammad/test.
    driver.browser.file_detector = nil
  end
end

Capybara.register_driver(:zammad_firefox) do |app|

  profile = Selenium::WebDriver::Firefox::Profile.new
  profile['intl.locale.matchOS']      = false
  profile['intl.accept_languages']    = 'en-US'
  profile['general.useragent.locale'] = 'en-US'
  profile['permissions.default.desktop-notification'] = 1 # ALLOW notifications

  options = {
    browser: :firefox,
    options: Selenium::WebDriver::Firefox::Options.new(profile: profile),
  }

  if ENV['REMOTE_URL'].present?
    options[:browser] = :remote
    options[:url]     = ENV['REMOTE_URL']
  end

  Capybara::Selenium::Driver.new(app, **options).tap do |driver|
    # Selenium 4 installs a default file_detector which finds wrong files/directories such as zammad/test.
    driver.browser.file_detector = nil
  end
end
