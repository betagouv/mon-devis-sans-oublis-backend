# frozen_string_literal: true

# Mail previews for QuoteCheckMailer
class QuoteCheckMailerPreview < ActionMailer::Preview
  def created
    quote_check = QuoteCheck.order("RANDOM()").first
    QuoteCheckMailer.created(quote_check)
  end
end
