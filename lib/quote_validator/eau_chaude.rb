# frozen_string_literal: true

#################################################
####         EAU CHAUDE SANITAIRE            ####
#################################################

# Validator for the Quote
module QuoteValidator
  class EauChaude < Base
    def validate_eau_chaude(geste, error)
      fields = {
        "marque_manquant" => :marque,
        "reference_manquant" => :reference,
        "volume_manquant" => :volume,
        "ETAS manquant" => :ETAS,
        "profil_soutirage_manquant" => :profil_soutirage
      }

      fields.each do |error_message, field|
        error << error_message if geste[field].blank?
      end
    end

    def validate_cesi(geste)
      error = []

      validate_eau_chaude(geste, error)

      fields = {
        "type_appoint_manquant" => :type_appoint, # electrique ou autre
        "surface_capteur_manquant" => :surface_capteur, # TODO: V1 > 2m2 en metropole pour MPR
        "classe_energetique_ballon_manquant" => :classe_energetique_ballon, # TODO: V1 minimum Classe C si volume ≤ 500L
        "fluide_manquant" => :fluide # eau, eau glucolée ou air
      }

      # TODO: V1 : Capteur hybrides produisant elec et chaleur exclus CEE uniquement ?
      # TODO V1 : Certification CSTBat ou Solar Keymark ou equivalente pour le ballon, uniquement CEE ?
      # TODO V1 : Véfifier valeur ETAS fonction de l'appoint et du profil de soutirage

      fields.each do |error_message, field|
        error << error_message if geste[field].blank?
      end

      error
    end

    def validate_chauffe_eau_thermodynamique(geste)
      error = []

      validate_eau_chaude(geste, error)
      fields = {
        "COP_manquant" => :COP, # COP de l’equipement mesuré conformément aux condition de la norme EN 16147
        # ≥ à 2,5 pour une installation sur air extrait,
        # ≥ à 2,4 dans les autres cas.
        "type_installation_manquant" => :type_installation # air exterieur, sr air exrait ou sur air ambiant -> Alors préciser la pièce TODO
      }

      # TODO: V1 : Véfifier valeur ETAS fonction du profil de soutirage

      fields.each do |error_message, field|
        error << error_message if geste[field].blank?
      end

      error
    end
  end
end
