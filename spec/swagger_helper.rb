# frozen_string_literal: true

require "rails_helper"

# Via Rswag gems
RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.openapi_root = Rails.root.join("swagger").to_s # TODO: doc

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under openapi_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a openapi_spec tag to the
  # the root example_group in your specs, e.g. describe '...', openapi_spec: 'v2/swagger.json'
  config.openapi_specs = {
    "v1/#{Rails.application.config.openapi_file.call('v1')}" => {
      openapi: "3.0.1",
      info: {
        title: "#{Rails.application.config.application_name} API V1",
        version: "v1"
      },
      paths: {},
      produces: ["application/json"],
      consumes: ["application/json"],
      components: {
        securitySchemes: {
          basic_auth: {
            type: :http,
            scheme: :basic
          }
          # TODO
          #   api_key: {
          #     type: :apiKey,
          #     name: "api_key",
          #     in: :query
          #   }
        },
        schemas: {
          api_error: {
            type: :object,
            properties: {
              error: { type: :string },
              message: {
                type: :array,
                items: { type: :string }
              }
            }
          },
          profile: {
            type: :string,
            enum: QuoteCheck::PROFILES
          },
          quote_check_status: {
            type: :string,
            enum: QuoteCheck::STATUSES,
            description: {
              "pending" => "analyse en cours",
              "valid" => "valide",
              "invalid" => "invalide"
            }.slice(*QuoteCheck::STATUSES).map { |status, description| "#{status}: #{description}" }.join(" | ")
          },
          quote_check_error_category: {
            type: :string,
            enum: QuoteValidator::Global.error_categories.keys,
            description: QuoteValidator::Global.error_categories.map do |category, description|
              "#{category}: #{description}"
            end.join(" | ")
          },
          quote_check_error_code: {
            type: :string,
            # enum: QuoteCheck::ERRORS, # TODO
            description: "code d'erreur"
          },
          quote_check_error_type: {
            type: :string,
            enum: QuoteValidator::Global.error_types.keys,
            description: QuoteValidator::Global.error_types.map do |type, description|
              "#{type}: #{description}"
            end.join(" | ")
          },
          quote_check_error_details: {
            type: "object",
            properties: {
              id: {
                type: :string,
                description: "UUID unique"
              },
              category: { "$ref" => "#/components/schemas/quote_check_error_category" },
              type: { "$ref" => "#/components/schemas/quote_check_error_type" },
              code: { "$ref" => "#/components/schemas/quote_check_error_code" },
              title: { type: :string },
              problem: { type: :string, description: "Réutilisez le title si vide" },
              solution: { type: :string, description: "peut-être vide" },
              provided_value: { type: :string },
              value: { type: :string, description: "DEPRECATED" }
            },
            required: %w[id code]
          },
          quote_check: {
            type: "object",
            properties: {
              id: {
                type: :string,
                description: "UUID unique"
              },
              status: { "$ref" => "#/components/schemas/quote_check_status" },
              profile: { "$ref" => "#/components/schemas/profile" },
              valid: { type: :boolean, nullable: true },
              errors: {
                type: :array,
                items: { "$ref" => "#/components/schemas/quote_check_error_code" },
                description: "liste des erreurs dans ordre à afficher",
                nullable: true
              },
              error_details: {
                type: :array,
                items: { "$ref" => "#/components/schemas/quote_check_error_details" },
                description: "liste des erreurs avec détails dans ordre à afficher",
                nullable: true
              },
              error_messages: {
                type: :object,
                additionalProperties: {
                  type: :string,
                  description: "code d'erreur => message"
                },
                nullable: true
              }
            },
            required: %w[id status profile]
          }
        }
      },
      servers: [ # Swagger reccomends to have path version listed inside server URLs
        {
          url: "https://api.staging.mon-devis-sans-oublis.beta.gouv.fr/api/v1",
          description: "Staging server"
        },
        {
          url: "https://api.mon-devis-sans-oublis.beta.gouv.fr/api/v1",
          description: "Production server"
        },
        {
          url: "http://localhost:3000/api/v1",
          description: "Development server"
        },
        if ENV.key?("APPLICATION_HOST") # current host
          {
            url: "http#{Rails.env.development? ? '' : 's'}://#{ENV.fetch('APPLICATION_HOST')}",
            variables: {
              defaultHost: {
                default: ENV.fetch("APPLICATION_HOST", "localhost:3000")
              }
            }
          }
        end,
        { # example host
          url: "http#{Rails.env.development? ? '' : 's'}://{defaultHost}",
          variables: {
            defaultHost: {
              default: ENV.fetch("APPLICATION_HOST", "localhost:3000")
            }
          }
        }
      ].compact.uniq { |server| server[:url] }
    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The openapi_specs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.openapi_format = :yaml
  # TODO: config.swagger_format = :json

  # TODO: config.openapi_strict_schema_validation = true
end
