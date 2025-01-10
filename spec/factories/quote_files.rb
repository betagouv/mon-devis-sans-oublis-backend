# frozen_string_literal: true

FactoryBot.define do
  factory :quote_file do
    filename { "Mon Devis.pdf" }
    sequence(:hexdigest) { "file_fixture quote.pdf #{it}" }
    content_type { "application/pdf" }
    uploaded_at { Time.zone.now }

    after(:build) do |quote_file|
      data = Rails.root.join("spec/fixtures/files/quote_files/Devis_test.pdf").open

      quote_file.data = data
      quote_file.file.attach(
        io: data,
        filename: "Devis_test.pdf",
        content_type: "application/pdf"
      )
    end
  end
end
