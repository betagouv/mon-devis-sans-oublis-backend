# frozen_string_literal: true

if Rails.env.production?
  GoodJob::Engine.middleware.use(Rack::Auth::Basic) do |username, password|
    ActiveSupport::SecurityUtils.secure_compare(ENV.fetch("GOOD_JOB_USERNAME"), username) &
      ActiveSupport::SecurityUtils.secure_compare(ENV.fetch("GOOD_JOB_PASSWORD"), password)
  end

  Rails.application.configure do |config|
    config.good_job.dashboard_default_locale = config.i18n.default_locale
  end
end
