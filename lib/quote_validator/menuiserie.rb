# frozen_string_literal: true

#################################################
####              MENUISERIE                 ####
#################################################

module QuoteValidator
  # Validator for the Quote
  class Menuiserie < Base
    # validation des critères communs à toutes les menuiseries
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity
    def validate_menuiserie(geste, error)
      error << "marque_manquant" if geste[:marque].blank?
      error << "reference_manquant" if geste[:reference].blank?
      error << "type_materiau_manquant" if geste[:type_materiau].blank? # bois, alu, pvc ...
      error << "type_vitrage_manquant" if geste[:type_vitrage].blank? # simple - double vitrage
      error << "type_pose_manquant" if geste[:type_pose].blank? # renovation ou depose totale
      error << "localisation_manquant" if geste[:localisation].blank?
      error << "position_paroie_manquant" if geste[:position_paroie].blank? # nu intérieur, nu extérieur, tunnel ...
    end
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/AbcSize

    def validate_menuiserie_fenetre(geste)
      error = []

      validate_menuiserie(geste, error)
      error << "uw_manquant" if geste[:uw].blank?
      error << "sw_manquant" if geste[:sw].blank?
      # V1, check valeurs : Uw ≤ 1,3 W/m².K et Sw ≥ 0,3 OU Uw ≤ 1,7 W/m².K et Sw ≥ 0,36

      error
    end

    def validate_menuiserie_fenetre_toit(geste)
      error = []

      validate_menuiserie(geste, error)
      error << "uw_manquant" if geste[:uw].blank?
      error << "sw_manquant" if geste[:sw].blank?
      # V1, check valeurs : (Uw ≤ 1,5 W/m².K et Sw ≤ 0,36 )

      error
    end

    def validate_menuiserie_porte(geste)
      error = []

      validate_menuiserie(geste, error)
      error << "ud_manquant" if geste[:ud].blank? # TODO : Que CEE ?
      # v1, check valeurs : Ud ≤ 1,7 W/m².K

      error
    end

    def validate_menuiserie_volet_isolant(geste)
      error = []

      validate_menuiserie(geste, error)

      error << "deltaR_manquant" if geste[:deltaR].blank? # TODO: Que CEE ?
      # v1, check valeurs :La résistance thermique additionnelle DeltaR (DeltaR ≥ 0,22 m².K/W)

      error
    end
  end
end
