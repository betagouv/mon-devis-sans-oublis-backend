# frozen_string_literal: true

require_relative "../../lib/uri_extended"

# frontend_origins = if Rails.env.production?
#                      [
#                        UriExtended.host_with_port(ENV.fetch("FRONTEND_APPLICATION_HOST")),
#                        Rails.application.config.app_env == "staging" ? "localhost" : nil
#                      ].compact
#                    else
#                      "*"
#                    end
frontend_origins = "*" # TODO: Remove me security issue

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins(*Array.wrap(frontend_origins))

    resource "/api/*",
             headers: :any,
             methods: %i[get post put patch delete options head],
             credentials: Rails.env.production?
  end
end
