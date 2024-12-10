# frozen_string_literal: true

# Notifies Sentry of errors
class ErrorNotifier
  def self.notify(error)
    Sentry.capture_exception(error)
  end
end
