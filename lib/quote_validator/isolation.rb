# frozen_string_literal: true

# Validator for the Quote
module QuoteValidator
  class Isolation < Base
    # doit valider les critères techniques associés aux gestes présents dans le devis
    def validate
      works = @quote[:gestes]
      works.each do |geste|
        case geste[:type]

        # ISOLATION
        when "isolation_mur_ite"
          validate_isolation_ite(geste)
        when "isolation_combles_perdues"
          validate_isolation_combles(geste)
        when "isolation_rampants-toiture"
          validate_isolation_rampants(geste)
        when "isolation_toiture_terrasse"
          validate_isolation_toiture_terrasse(geste)
        when "isolation_mur_iti"
          validate_isolation_iti(geste)
        when "isolation_plancher_bas"
          validate_isolation_plancher_bas(geste)

        end
      end
    end

    #################################################
    ####              ISOLATION                  ####
    #################################################

    # Validation des critères communs aux différentes isolations
    def validate_isolation(geste, error)
      error << "marque_manquant" if geste[:marque].blank?
      error << "reference_manquant" if geste[:reference].blank?
      error << "surface_manquant" if geste[:surface].blank? # TODO : check unité ?
      error << "epaisseur_manquant" if geste[:epaisseur].blank? # TODO : check unité ?
      error << "R_manquant" if geste[:R].blank?

      # TODO : V1 - vérifier les normes
    end

    def validate_isolation_ite(geste)
      error_ite = []

      validate_isolation(geste, error_ite)
      # TODO : check valeur R en V1 - R ≥ 3,7 m².K/W ou R ≥ 4.4 m².K/W si MAR

      # TODO : V1 - présence parement, protection et fixation (pour être éligible MPR, TODO quid CEE)
      errors << eror_ite
    end

    def validate_isolation_combles(geste)
      error_comble = []

      validate_isolation(geste, error_comble)
      # TODO : check valeur R en V1 - R  ≥ 7 m².K/W MPR

      errors << error_comble
    end

    def validate_isolation_rampants(geste)
      error_rampant = []

      validate_isolation(geste, error_rampant)
      # TODO : check valeur R en V1 - R  ≥ 6 m².K/W MPR

      errors << eror_rampant
    end

    def validate_isolation_toiture_terrasse(geste)
      error_toiture = []

      validate_isolation(geste, error_toiture)
      # TODO : check valeur R en V1 - R ≥ 4,5 m².K/W ou R ≥ 6,5 m².K/W si MAR
      error_toiture << "type_isolation_toiture_terrasse_manquant" if geste[:type_isolation_toiture_terrasse].blank?

      errors << eror_toiture
    end

    def validate_isolation_iti(geste)
      error_iti = []

      validate_isolation(geste, error_iti)
      # TODO : check valeur R en V1 - R ≥ 3,70 m².K/W
      # Protection des conduits de fumées

      # TODO : V1 - présence parement, protection et fixation (pour être éligible MPR, TODO quid CEE)
      errors << eror_iti
    end

    def validate_isolation_plancher_bas(geste)
      error_plancher = []

      validate_isolation(geste, error_plancher)
      # TODO : check valeur R en V1 - R ≥ 3 m².K/W pour les planchers bas sur sous-sol, sur vide sanitaire ou sur passage ouvert
      error_toiture << "localisation_manquant" if geste[:localisation].blank?
      errors << eror_plancher
    end
  end
end
