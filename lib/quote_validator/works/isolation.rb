# frozen_string_literal: true

#################################################
####              ISOLATION                  ####
#################################################

module QuoteValidator
  module Works
    # Validator for the Work
    class Isolation < Base
      # Validation des critères communs aux différentes isolations
      def validate_isolation(geste)
        add_error("isolation_marque_manquant", geste) if geste[:marque_isolant].blank?
        add_error("isolation_reference_manquant", geste) if geste[:reference_isolant].blank?
        add_error("isolation_surface_manquant", geste) if geste[:surface_isolant].blank? # TODO : check unité ?
        add_error("isolation_epaisseur_manquant", geste) if geste[:epaisseur_isolant].blank? # TODO : check unité ?
        add_error("isolation_r_manquant", geste) if geste[:resistance_thermique].blank?

        # TODO : V1 - vérifier les normes
        validate_norme(geste)
      end

      def validate_norme(geste)
        acermi = geste[:numero_acermi]
        norme = geste[:norme_calcul_resistance]
        return unless norme.blank? && acermi.blank?

        add_error("isolation_norme_acermi_manquant", geste)
      end

      def validate_protection(geste)
        return unless !geste[:presence_parement] && !geste[:presence_protection] && !geste[:presence_fixation]

        add_error("isolation_parement_fixation_protection_manquant", geste)
      end

      def validate_isolation_ite(geste)
        validate_isolation(geste)
        # TODO : check valeur R en V1 - R ≥ 3,7 m².K/W ou R ≥ 4.4 m².K/W si MAR

        # TODO : V1 - présence parement, protection et fixation (pour être éligible MPR, TODO quid CEE)
        validate_protection(geste)
      end

      def validate_isolation_combles(geste)
        validate_isolation(geste)
        # TODO : check valeur R en V1 - R  ≥ 7 m².K/W MPR
      end

      def validate_isolation_rampants(geste)
        validate_isolation(geste)
        # TODO : check valeur R en V1 - R  ≥ 6 m².K/W MPR
      end

      def validate_isolation_toiture_terrasse(geste)
        validate_isolation(geste)

        # TODO : check valeur R en V1 - R ≥ 4,5 m².K/W ou R ≥ 6,5 m².K/W si MAR
        return if geste[:type_isolation_toiture_terrasse].present?

        add_error("isolation_type_isolation_toiture_terrasse_manquant", geste)
      end

      def validate_isolation_iti(geste)
        validate_isolation(geste)
        # TODO : check valeur R en V1 - R ≥ 3,70 m².K/W
        # Protection des conduits de fumées

        # TODO : V1 - présence parement, protection et fixation (pour être éligible MPR, TODO quid CEE)
        validate_protection(geste)
      end

      def validate_isolation_plancher_bas(geste)
        validate_isolation(geste)

        # TODO : check valeur R en V1 - R ≥ 3 m².K/W pour les planchers bas sur sous-sol,
        # sur vide sanitaire ou sur passage ouvert

        add_error("isolation_localisation_plancher_bas_manquant", geste) if geste[:localisation].blank?
      end

      protected

      def add_error(code, geste, type: "missing")
        super(code,
                  type:,
                  category: "gestes",
                  geste:,
                  provided_value: geste[:intitule])
      end
    end
  end
end
