# frozen_string_literal: true

FactoryBot.define do
  factory :quote_file do
    filename { "MyString" }
    hexdigest { "file_fixture quote.pdf" }
    content_type { "application/pdf" }
    uploaded_at { "2024-11-26 19:35:07" }

    after(:build) do |quote_check|
      quote_check.file.attach(
        io: Rails.root.join("spec/fixtures/files/quote_files/Devis_test.pdf").open,
        filename: "Devis_test.pdf",
        content_type: "application/pdf"
      )
    end
  end
end
