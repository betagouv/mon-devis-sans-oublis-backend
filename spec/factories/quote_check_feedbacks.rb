# frozen_string_literal: true

FactoryBot.define do
  factory :quote_check_feedback do
    quote_check { association(:quote_check, :invalid) }

    trait :error_detail do
      validation_error_details_id { quote_check.validation_error_details.sample.fetch("id") }
      is_helpful { [true, false].sample }
    end
    trait :global do
      rating { rand(0..5) }
      email { Faker::Internet.email }
    end

    comment { "MyComment" }
  end
end
