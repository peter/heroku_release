require 'bundler'
Bundler.require(:development)

$:.unshift(File.join(File.dirname(__FILE__), "..", "lib"))
require 'heroku_release'

RSpec.configure do |config|
  config.mock_with :mocha
end
