# frozen_string_literal: true

#################################################
####              VENTILATION                ####
#################################################

# Validator for the Quote
module QuoteValidator
  class Chauffage < Base
    def validate_ventilation(geste, error)
      fields = {
        "type_vmc_manquant" => :type_vmc,
        # VMC simple flux hygroréable de type A (Hygro A)
        # VMC simple flux hygroréable de type B (Hygro B)
        # VMC double flux avec échangeur
        "marque_caisson_manquant" => :marque_caisson,
        "reference_caisson_manquant" => :reference_caisson,
        "marque_bouche_extraction" => :marque_bouche_extraction,
        "reference_bouche_extraction" => :reference_bouche_extraction,
        "nombre_bouche_extraction" => :nombre_bouche_extraction,
        "classe_caisson_manquant" => :classe_caisson,
        "puissance" => :puissance # Puissance electrique du moteur en fonction de la config du logement exprimé en (W-Th-C)  (doit être basse conso)
      }

      fields.each do |error_message, field|
        error << error_message if geste[field].blank?
      end
    end

    def validate_vmc_simple_flux(geste)
      error = []

      validate_ventilation(geste, error)
      fields = {}

      # TODO : - Marque et référence et type des bouches d’entrée d’air
      # Nombre et emplacement (pour rappel uniquement dans les pièces seches)
      # Si menuisier qui installe → à Préciser dans le devis

      # TODO: V1 : vérifier classe energetique du caisson B ou supérieur
      # TODO V1 : ⇒ Caisson basse conso avec puissance electrique absobée pondéréé ≤ 15 WThC (configuration T4 avec 1 salle de bain et 1WC)

      fields.each do |error_message, field|
        error << error_message if geste[field].blank?
      end

      error
    end

    def validate_vmc_double_flux(geste)
      error = []

      validate_ventilation(geste, error)
      fields = {}

      # TODO: V1 :
      # Marque et référence  nombre et emplace des bouches de soufflage
      # Caisson de classe d’efficacité énergétique A ou supérieur (MPR)
      # Efficacité thermique de l’échangeur > 85% (Equivalent à un caisson certifié NF 205 ou equivalent)

      fields.each do |error_message, field|
        error << error_message if geste[field].blank?
      end

      error
    end
  end
end
