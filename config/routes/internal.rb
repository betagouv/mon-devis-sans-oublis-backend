# frozen_string_literal: true

Rails.application.routes.draw do
  mount GoodJob::Engine => "mdso_good_job"
end
