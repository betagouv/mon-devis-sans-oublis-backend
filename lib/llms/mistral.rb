# frozen_string_literal: true

require "net/http"
require "json"
require "uri"

module Llms
  # Mistral API client
  class Mistral
    class ResultError < StandardError; end

    attr_reader :prompt, :read_attributes, :result

    def initialize(prompt)
      @api_key = ENV.fetch("MISTRAL_API_KEY")
      @prompt = prompt
    end

    # Returns the cost in € with VAT
    PROMPT_TOKEN_COST = 0.0018 / 1000 * 1.2
    COMPLETION_TOKEN_COST = 0.0054 / 1000 * 1.2
    def self.usage_cost_price(prompt_tokens: 0, completion_tokens: 0)
      # Rounded to the last started thousand
      price = ((prompt_tokens.to_f / 1000).ceil * 1000 * PROMPT_TOKEN_COST).ceil(2) +
              ((completion_tokens.to_f / 1000).ceil * 1000 * COMPLETION_TOKEN_COST).ceil(2)
      price.ceil(2)
    end

    def self.configured?
      ENV.key?("MISTRAL_API_KEY")
    end

    def self.extract_json(text)
      text[/(\{.+\})/im, 1]
    end

    def self.extract_jsx(text)
      text[/(\{.+\})/im, 1] if text&.match?(/```jsx\n/i)
    end

    # API Docs: https://docs.mistral.ai/api/#tag/chat/operation/chat_completion_v1_chat_completions_post
    # TODO: Better client
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def chat_completion(text)
      uri = URI("https://api.mistral.ai/v1/chat/completions")
      headers = {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{@api_key}"
      }
      body = {
        model: "mistral-large-latest",
        messages: [
          { role: "user", content: prompt },
          { role: "user", content: text }
        ]
      }

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        request = Net::HTTP::Post.new(uri, headers)
        request.body = body.to_json
        http.request(request)
      end

      raise ResultError, "Error: #{response.code} - #{response.message}" unless response.is_a?(Net::HTTPSuccess)

      @result = JSON.parse(response.body)
      content = result.dig("choices", 0, "message", "content")
      raise ResultError, "Content empty" unless content

      content_jsx_result = self.class.extract_jsx(content)
      if content_jsx_result
        @read_attributes = eval(content_jsx_result.gsub(/: +null/i, ": nil")) # rubocop:disable Security/Eval
      else
        content_json_result = self.class.extract_json(content)
        @read_attributes = begin
          JSON.parse(content_json_result, symbolize_names: true)
        rescue JSON::ParserError
          raise ResultError, "Parsing JSON inside content: #{content_json_result}"
        end
      end
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/AbcSize

    def model
      result&.fetch("model")
    end

    def usage
      result&.fetch("usage")
    end
  end
end
