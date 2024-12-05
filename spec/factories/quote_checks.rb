# frozen_string_literal: true

FactoryBot.define do
  factory :quote_check do
    file factory: %i[quote_file]

    profile { "artisan" }
    text { "MyText" }
    anonymised_text { "MyText" }

    naive_attributes { {} }
    naive_version { "MyString" }
    qa_attributes { {} }
    qa_result { {} }
    qa_version { QuoteReader::Qa::VERSION }
    read_attributes { {} }

    validation_errors { {} }
    validation_version { QuoteValidator::Global::VERSION }

    started_at { "2024-11-27 11:33:58" }
    finished_at { "2024-11-27 11:32:58" }
  end
end
