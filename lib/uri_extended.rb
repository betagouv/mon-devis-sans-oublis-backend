# frozen_string_literal: true

# Extend URI class
class UriExtended
  # Extract host and port if provided
  def self.host_with_port(url)
    uri = URI.parse(url)
    "#{uri.host}#{":#{uri.port}" if uri.port}"
  rescue URI::InvalidURIError
    nil
  end
end
