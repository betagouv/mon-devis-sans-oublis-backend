# frozen_string_literal: true

Rails.application.routes.draw do
  scope "mdso" do
    ActiveAdmin.routes(self)
  end

  mount GoodJob::Engine => "mdso_good_job"
end
