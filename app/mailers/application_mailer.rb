# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("DEFAULT_EMAIL_FROM", "from@example.com")
  layout "mailer"

  def subject(text)
    subject_parts = ["[#{Rails.application.config.application_name}]"]

    if ENV.key?("APP_ENV") && ENV["APP_ENV"] != "production"
      subject_parts << "[#{ENV.fetch('APP_ENV')}]"
    elsif !Rails.env.production?
      subject_parts << "[#{Rails.env}]"
    end

    subject_parts << text

    subject_parts.join(" ")
  end
end
