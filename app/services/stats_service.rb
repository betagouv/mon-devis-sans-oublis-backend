# frozen_string_literal: true

# This class is responsible to compute stats
class StatsService
  def self.keys
    new.methods.sort - Object.methods - [:all]
  end

  def all
    {
      quote_checks_count:,
      average_quote_check_errors_count:,
      average_quote_check_cost:,
      unique_visitors_count:
    }
  end

  protected

  # rubocop:disable Metrics/MethodLength
  def average_quote_check_cost
    quote_checks_qith_qa = QuoteCheck.where.not(qa_result: nil)
    return nil if quote_checks_qith_qa.count.zero?

    costs = quote_checks_qith_qa.pluck(:qa_result).flat_map do |qa_result|
      if qa_result.key?("usage")
        usage = qa_result.fetch("usage")
        Llms::Mistral.usage_cost_price(
          completion_tokens: usage.fetch("completion_tokens"),
          prompt_tokens: usage.fetch("prompt_tokens")
        )
      end
    end
    (costs.sum.to_f / costs.size).ceil(2)
  end
  # rubocop:enable Metrics/MethodLength

  def average_quote_check_errors_count
    return nil if QuoteCheck.count.zero?

    total_errors_count = QuoteCheck.where.not(validation_errors: nil).pluck(:validation_errors).sum(&:size)
    (total_errors_count.to_f / QuoteCheck.count).ceil(1)
  end

  def quote_checks_count
    QuoteCheck.count
  end

  def unique_visitors_count
    MatomoApi.new.value(method: "VisitsSummary.getUniqueVisitors") if MatomoApi.auto_configured?
  end
end
