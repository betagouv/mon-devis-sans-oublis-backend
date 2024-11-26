# frozen_string_literal: true

require "net/http"
require "json"
require "uri"

module Llms
  # Mistral API client
  class Mistral
    class ResultError < StandardError; end

    attr_reader :prompt

    def initialize(prompt)
      @api_key = ENV.fetch("MISTRAL_API_KEY")
      @prompt = prompt
    end

    def self.configured?
      ENV.key?("MISTRAL_API_KEY")
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

      result = JSON.parse(response.body)
      content = result.dig("choices", 0, "message", "content")
      json_result = content[/(\{.+\})/im, 1]
      JSON.parse(json_result)
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/AbcSize
  end
end