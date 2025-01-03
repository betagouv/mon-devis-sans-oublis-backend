# frozen_string_literal: true

require "json"
require "net/http"
require "uri"

require_relative "base"

module Llms
  # Albert API client : following OpenAI API structure
  # Documentation https://github.com/etalab-ia/albert-api
  class Albert < Base
    attr_reader :prompt, :read_attributes, :result

    def initialize(prompt)
      super
      @api_key = ENV.fetch("ALBERT_API_KEY")
    end

    def self.configured?
      ENV.key?("ALBERT_API_KEY")
    end

    # API Docs: https://docs.mistral.ai/api/#tag/chat/operation/chat_completion_v1_chat_completions_post
    # TODO: Better client
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    # model:
    # - meta-llama/Meta-Llama-3.1-8B-Instruct
    # - meta-llama/Meta-Llama-3.1-70B-Instruct
    # - AgentPublic/llama3-instruct-8b (default)
    # - AgentPublic/Llama-3.1-8B-Instruct
    def chat_completion(text, model: "meta-llama/Meta-Llama-3.1-70B-Instruct")
      uri = URI("https://albert.api.etalab.gouv.fr/v1/chat/completions")
      headers = {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{@api_key}"
      }
      body = {
        model:,
        messages: [
          { role: "system", content: prompt },
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
