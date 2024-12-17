# frozen_string_literal: true

# Helper to encode HTTP Basic Auth credentials
module ApiHelper
  def basic_auth_header(username: "mdso", password: ENV.fetch("MDSO_SITE_PASSWORD"))
    credentials = ActionController::HttpAuthentication::Basic.encode_credentials(username, password)
    { "Authorization" => credentials }
  end
end
