# frozen_string_literal: true

#################################################
####         EAU CHAUDE SANITAIRE            ####
#################################################

module QuoteValidator
  module Works
    # Validator for the Work
    class EauChaude < Base
      def validate_eau_chaude(geste)
        fields = {
          "marque_eau_chaude_manquant" => :marque,
          "reference_eau_chaude_manquant" => :reference,
          "volume_manquant" => :volume,
          "etas_eau_chaude_manquant" => :ETAS,
          "profil_soutirage_manquant" => :profil_soutirage
        }

        fields.each do |error_message, field|
          add_error(error_message, geste) if geste[field].blank?
        end
      end

      # chauffe eau solaire individuel
      def validate_cesi(geste)
        validate_eau_chaude(geste)

        fields = {
          "type_appoint_manquant" => :type_appoint, # electrique ou autre
          "surface_capteur_manquant" => :surface_capteur, # TODO: V1 > 2m2 en metropole pour MPR
          "classe_energetique_ballon_manquant" => :classe_energetique_ballon,
          # TODO: V1 minimum Classe C si volume ≤ 500L
          "fluide_manquant" => :fluide # eau, eau glucolée ou air
        }

        # TODO: V1 : Capteur hybrides produisant elec et chaleur exclus CEE uniquement ?
        # TODO V1 : Certification CSTBat ou Solar Keymark ou equivalente pour le ballon, uniquement CEE ?
        # TODO V1 : Véfifier valeur ETAS fonction de l'appoint et du profil de soutirage

        fields.each do |error_message, field|
          add_error(error_message, geste) if geste[field].blank?
        end
      end

      def validate_chauffe_eau_thermodynamique(geste)
        validate_eau_chaude(geste)

        fields = {
          "cop_eau_chaude_manquant" => :COP,
          # COP de l’equipement mesuré conformément aux condition de la norme EN 16147
          # ≥ à 2,5 pour une installation sur air extrait,
          # ≥ à 2,4 dans les autres cas.
          "type_installation_manquant" => :type_installation # air exterieur, sur air exrait ou sur air ambiant
          # -> Alors préciser la pièce TODO
        }

        # TODO: V1 : Véfifier valeur ETAS fonction du profil de soutirage

        fields.each do |error_message, field|
          add_error(error_message, geste) if geste[field].blank?
        end
      end

      def add_error(code, geste)
        super(code,
                  type: "missing",
                  category: "gestes",
                  value: geste[:intitule])
      end
    end
  end
end