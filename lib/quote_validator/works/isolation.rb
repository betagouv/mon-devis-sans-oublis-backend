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
        add_error("marque_isolation_manquant", geste) if geste[:marque].blank?
        add_error("reference_isolation_manquant", geste) if geste[:reference].blank?
        add_error("surface_manquant", geste) if geste[:surface].blank? # TODO : check unité ?
        add_error("epaisseur_manquant", geste) if geste[:epaisseur].blank? # TODO : check unité ?
        add_error("r_manquant", geste) if geste[:resistance_thermique].blank?

        # TODO : V1 - vérifier les normes
      end

      def validate_isolation_ite(geste)
        validate_isolation(geste)
        # TODO : check valeur R en V1 - R ≥ 3,7 m².K/W ou R ≥ 4.4 m².K/W si MAR

        # TODO : V1 - présence parement, protection et fixation (pour être éligible MPR, TODO quid CEE)
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
        add_error("type_isolation_toiture_terrasse_manquant", geste) if geste[:type_isolation_toiture_terrasse].blank?
      end

      def validate_isolation_iti(geste)
        validate_isolation(geste)
        # TODO : check valeur R en V1 - R ≥ 3,70 m².K/W
        # Protection des conduits de fumées

        # TODO : V1 - présence parement, protection et fixation (pour être éligible MPR, TODO quid CEE)
      end

      def validate_isolation_plancher_bas(geste)
        validate_isolation(geste)

        # TODO : check valeur R en V1 - R ≥ 3 m².K/W pour les planchers bas sur sous-sol,
        # sur vide sanitaire ou sur passage ouvert

        add_error("localisation_manquant", geste) if geste[:localisation].blank?
      end

      protected

      def add_error(code, geste)
        super(code,
                  type: "missing",
                  category: "gestes",
                  provided_value: geste[:intitule])
      end
    end
  end
end
