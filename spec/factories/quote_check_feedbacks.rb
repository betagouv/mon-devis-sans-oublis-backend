# frozen_string_literal: true

FactoryBot.define do
  factory :quote_check_feedback do
    quote_check { association(:quote_check, :invalid) }

    validation_error_details_id { quote_check.validation_error_details.sample.fetch("id") }
    is_helpful { [true, false].sample }
    comment { "MyComment" }
  end
end
