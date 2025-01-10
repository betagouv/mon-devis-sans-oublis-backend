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
      average_quote_check_processing_time:,
      average_quote_check_cost:,
      unique_visitors_count:
    }
  end

  protected

  def average_quote_check_cost
    quote_checks_with_qa = QuoteCheck.where.not(qa_result: nil)
    return nil if quote_checks_with_qa.count.zero?

    costs = quote_checks_with_qa.select(:qa_result).flat_map(&:cost)
    (costs.sum.to_f / costs.size).ceil(2)
  end

  def average_quote_check_errors_count
    return nil if QuoteCheck.count.zero?

    total_errors_count = QuoteCheck.where.not(validation_errors: nil).pluck(:validation_errors).sum(&:size)
    (total_errors_count.to_f / QuoteCheck.count).ceil(1)
  end

  # In seconds
  def average_quote_check_processing_time
    quote_checks_finished = QuoteCheck.where.not(finished_at: nil)
    return nil if quote_checks_finished.count.zero?

    total_processing_time = quote_checks_finished.select(:finished_at, :started_at).sum { it.processing_time }
    (total_processing_time.to_f / quote_checks_finished.count).ceil
  end

  def quote_checks_count
    QuoteCheck.count
  end

  def unique_visitors_count
    MatomoApi.new.value(method: "VisitsSummary.getUniqueVisitors") if MatomoApi.auto_configured?
  end
end
