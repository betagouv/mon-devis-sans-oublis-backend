# frozen_string_literal: true

class QuoteCheckMailer < ApplicationMailer
  def created(quote_check)
    @quote_check = quote_check

    recipients = ENV["QUOTE_CHECK_EMAIL_RECIPIENTS"]&.split(",")
    return if recipients.blank?

    mail(
      to: recipients.first,
      cc: recipients[1..],
      subject: subject("Nouveau devis soumis #{quote_check.id}")
    )
  end
end
