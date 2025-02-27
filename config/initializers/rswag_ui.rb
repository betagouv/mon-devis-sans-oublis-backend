# frozen_string_literal: true

Rswag::Ui.configure do |config|
  # List the Swagger endpoints that you want to be documented through the
  # swagger-ui. The first parameter is the path (absolute or relative to the UI
  # host) to the corresponding endpoint and the second is a title that will be
  # displayed in the document selector.
  # NOTE: If you're using rspec-api to expose Swagger files
  # (under openapi_root) as JSON or YAML endpoints, then the list below should
  # correspond to the relative paths for those endpoints.

  config.openapi_endpoint "/api-docs/v1/#{Rails.application.config.openapi_file.call('v1')}",
                          "#{Rails.application.config.application_name} API V1 Documentation"

  config.basic_auth_enabled = true
  config.basic_auth_credentials "mdso", ENV.fetch("MDSO_SITE_PASSWORD")
end
