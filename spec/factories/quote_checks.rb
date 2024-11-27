# frozen_string_literal: true

FactoryBot.define do
  factory :quote_check do
    file { nil }
    profile { "MyString" }
    text { "MyText" }
    anonymised_text { "MyText" }
    naive_attributes { "" }
    qa_attributes { "" }
    naive_version { "MyString" }
    qa_version { "MyString" }
    read_attributes { "" }
    validation { "" }
    validation_version { "MyString" }
    started_at { "2024-11-27 11:33:58" }
  end
end
