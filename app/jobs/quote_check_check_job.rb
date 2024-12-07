# frozen_string_literal: true

# Job to (re)check an existing QuoteCheck
class QuoteCheckCheckJob < ApplicationJob
  queue_as :default

  def perform(quote_check_id)
    quote_check = QuoteCheck.find(quote_check_id)
    QuoteCheckCheckService.new(quote_check).check
  end
end
