# frozen_string_literal: true

# Makes QuoteCheck easier for the Backoffice
module QuoteCheckBackoffice
  def self.ransackable_attributes(_auth_object = nil)
    %i[with_expected_value]
  end

  def frontend_webapp_url
    return unless id

    profile_path = case profile
                   when "artisan" then "artisan"
                   when "conseiller" then "conseiller"
                   when "mandataire" then "mandataire"
                   when "particulier" then "particulier"
                   else
                     raise NotImplementedError, "Unknown path for profile: #{profile}"
                   end

    URI.join("#{ENV.fetch('FRONTEND_APPLICATION_HOST')}/", "#{profile_path}/", "televersement/", id).to_s
  end
end
