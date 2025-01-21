# frozen_string_literal: true

require_relative "../../lib/uri_extended"

frontend_origins = UriExtended.host_with_port(ENV.fetch("FRONTEND_APPLICATION_HOST", "http://localhost:3000"))

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins Rails.env.production? ? frontend_origins : "*"

    resource "/api/*",
             headers: :any,
             methods: %i[get post put patch delete options head],
             credentials: Rails.env.production?
  end
end
