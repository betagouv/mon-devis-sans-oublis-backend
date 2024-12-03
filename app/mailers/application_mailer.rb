# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("DEFAULT_EMAIL_FROM", "from@example.com")
  layout "mailer"

  def subject(text)
    subject_parts = [
      "[#{Rails.application.config.application_name}]",
      text
    ]
    subject_parts << " [#{Rails.env}]" unless Rails.env.production?

    subject_parts.join(" ")
  end
end
