# frozen_string_literal: true

#################################################
####              ISOLATION                  ####
#################################################

module QuoteValidator
  # Validator for the Quote
  class Isolation < Base
    # Validation des critères communs aux différentes isolations
    def validate_isolation(geste, error)
      error << "marque_isolation_manquant" if geste[:marque].blank?
      error << "reference_isolation_manquant" if geste[:reference].blank?
      error << "surface_manquant" if geste[:surface].blank? # TODO : check unité ?
      error << "epaisseur_manquant" if geste[:epaisseur].blank? # TODO : check unité ?
      error << "R_manquant" if geste[:Resistance_thermique].blank?

      # TODO : V1 - vérifier les normes
    end

    def validate_isolation_ite(geste)
      error_ite = []

      validate_isolation(geste, error_ite)
      # TODO : check valeur R en V1 - R ≥ 3,7 m².K/W ou R ≥ 4.4 m².K/W si MAR

      # TODO : V1 - présence parement, protection et fixation (pour être éligible MPR, TODO quid CEE)
      eror_ite
    end

    def validate_isolation_combles(geste)
      error_comble = []

      validate_isolation(geste, error_comble)
      # TODO : check valeur R en V1 - R  ≥ 7 m².K/W MPR

      error_comble
    end

    def validate_isolation_rampants(geste)
      error_rampant = []

      validate_isolation(geste, error_rampant)
      # TODO : check valeur R en V1 - R  ≥ 6 m².K/W MPR

      eror_rampant
    end

    def validate_isolation_toiture_terrasse(geste)
      error_toiture = []

      validate_isolation(geste, error_toiture)
      # TODO : check valeur R en V1 - R ≥ 4,5 m².K/W ou R ≥ 6,5 m².K/W si MAR
      error_toiture << "type_isolation_toiture_terrasse_manquant" if geste[:type_isolation_toiture_terrasse].blank?

      eror_toiture
    end

    def validate_isolation_iti(geste)
      error_iti = []

      validate_isolation(geste, error_iti)
      # TODO : check valeur R en V1 - R ≥ 3,70 m².K/W
      # Protection des conduits de fumées

      # TODO : V1 - présence parement, protection et fixation (pour être éligible MPR, TODO quid CEE)
      eror_iti
    end

    def validate_isolation_plancher_bas(geste)
      error_plancher = []

      validate_isolation(geste, error_plancher)
      # TODO : check valeur R en V1 - R ≥ 3 m².K/W pour les planchers bas sur sous-sol,
      # sur vide sanitaire ou sur passage ouvert
      error_toiture << "localisation_manquant" if geste[:localisation].blank?
      eror_plancher
    end
  end
end
