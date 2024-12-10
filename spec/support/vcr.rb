# frozen_string_literal: true

require "vcr"
require "webmock/rspec"

WebMock.disable_net_connect!(allow_localhost: true)

VCR.configure do |config|
  config.cassette_library_dir = "spec/vcr_cassettes" # Directory where cassettes will be stored
  config.hook_into :webmock # Use WebMock to intercept HTTP requests
  config.configure_rspec_metadata! # Automatically tag RSpec examples with cassette metadata
  config.allow_http_connections_when_no_cassette = true # So we can upsert new cassettes
  config.ignore_localhost = true
  config.debug_logger = File.open("log/vcr_debug.log", "w")

  config.filter_sensitive_data("<MISTRAL_API_KEY>") { ENV.fetch("MISTRAL_API_KEY") }
end
