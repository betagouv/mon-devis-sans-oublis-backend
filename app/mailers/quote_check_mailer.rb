# frozen_string_literal: true

class QuoteCheckMailer < ApplicationMailer
  def created(quote_check)
    @quote_check = quote_check

    return if admin_recipients.blank?

    mail(
      to: recipients.first,
      cc: recipients[1..],
      subject: subject("Nouveau devis soumis #{quote_check.id}")
    )
  end

  private

  def admin_recipients
    @admin_recipients ||= ENV["QUOTE_CHECK_EMAIL_RECIPIENTS"]&.strip&.split(",")
  end
end
