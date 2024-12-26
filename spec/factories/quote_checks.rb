# frozen_string_literal: true

FactoryBot.define do
  factory :quote_check do
    profile { "artisan" }
    file factory: %i[quote_file]

    started_at { Time.zone.now }
    finished_at { nil } # Default pending status

    trait :finished do
      text { "MyText" }
      anonymised_text { "MyText" }

      naive_attributes { {} }
      naive_version { "MyString" }
      qa_attributes { {} }
      qa_result { {} }
      qa_version { QuoteReader::Qa::VERSION }
      read_attributes { {} }

      finished_at { 5.minutes.from_now }

      validation_version { QuoteValidator::Global::VERSION }
      validation_errors { [] }
    end
    trait :valid do
      finished

      validation_version { QuoteValidator::Global::VERSION }
      validation_errors { [] }
    end
    trait :invalid do
      finished

      validation_version { QuoteValidator::Global::VERSION }
      validation_errors { validation_error_details&.map { |error_detail| error_detail.fetch(:code) } || [] }
      validation_error_details do
        [{
          id: "1",
          code: "something"
        }]
      end
    end
  end
end
