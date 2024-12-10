# frozen_string_literal: true

# Notifies Sentry of errors
class ErrorNotifier
  def self.notify(error)
    Sentry.capture_exception(error) if defined?(Sentry)
    Rails.logger.error(error)
  end
end
