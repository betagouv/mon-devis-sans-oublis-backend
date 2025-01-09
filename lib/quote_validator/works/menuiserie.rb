# frozen_string_literal: true

#################################################
####              MENUISERIE                 ####
#################################################

module QuoteValidator
  module Works
    # Validator for the Work
    class Menuiserie < Base
      # validation des critères communs à toutes les menuiseries
      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/CyclomaticComplexity
      def validate_menuiserie(geste)
        add_error("menuiserie_marque_manquant", geste) if geste[:marque].blank?
        add_error("menuiserie_reference_manquant", geste) if geste[:reference].blank?
        add_error("menuiserie_type_materiau_manquant", geste) if geste[:type_materiau].blank? # bois, alu, pvc ...
        add_error("menuiserie_type_vitrage_manquant", geste) if geste[:type_vitrage].blank? # simple - double vitrage
        add_error("menuiserie_type_pose_manquant", geste) if geste[:type_pose].blank? # renovation ou depose totale
        add_error("menuiserie_localisation_manquant", geste) if geste[:localisation].blank?
        add_error("menuiserie_position_paroie_manquant", geste) if geste[:position_paroie].blank?
        # nu intérieur, nu extérieur, tunnel ...
      end
      # rubocop:enable Metrics/CyclomaticComplexity
      # rubocop:enable Metrics/AbcSize

      def validate_menuiserie_fenetre(geste)
        validate_menuiserie(geste)
        add_error("menuiserie_uw_fenetre_manquant", geste) if geste[:uw].blank?
        add_error("menuiserie_sw_fenetre_manquant", geste) if geste[:sw].blank?
        # V1, check valeurs : Uw ≤ 1,3 W/m².K et Sw ≥ 0,3 OU Uw ≤ 1,7 W/m².K et Sw ≥ 0,36
      end

      def validate_menuiserie_fenetre_toit(geste)
        validate_menuiserie(geste)
        add_error("menuiserie_uw_fenetre_toit_manquant", geste) if geste[:uw].blank?
        add_error("menuiserie_sw_fenetre_toit_manquant", geste) if geste[:sw].blank?
        # V1, check valeurs : (Uw ≤ 1,5 W/m².K et Sw ≤ 0,36 )
      end

      def validate_menuiserie_porte(geste)
        validate_menuiserie(geste)
        add_error("menuiserie_ud_porte_manquant", geste) if geste[:ud].blank? # TODO : Que CEE ?
        # v1, check valeurs : Ud ≤ 1,7 W/m².K
      end

      def validate_menuiserie_volet_isolant(geste)
        validate_menuiserie(geste)

        add_error("menuiserie_deltar_volet_manquant", geste) if geste[:deltaR].blank? # TODO: Que CEE ?
        # v1, check valeurs :La résistance thermique additionnelle DeltaR (DeltaR ≥ 0,22 m².K/W)
      end

      protected

      def add_error(code, geste, type: "missing")
        super(code,
                  type:,
                  category: "gestes",
                  value: geste[:intitule])
      end
    end
  end
end
