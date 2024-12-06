# frozen_string_literal: true

#################################################
####              CHAUFFAGE                  ####
#################################################

module QuoteValidator
  # Validator for the Quote
  class Chauffage < Base
    def validate_chauffage(geste, error)
      error << "puissance_manquant" if geste[:puissance].blank?
      error << "marque_manquant" if geste[:marque].blank?
      error << "reference_manquant" if geste[:reference].blank?
      error << "ETAS_chauffage_manquant" if geste[:ETAS].blank # en %

      # TODO: à challenger
      @warnings << "remplacement_chaudiere_condensation_manquant" if !geste[:remplacement_chaudiere_condensation]
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/PerceivedComplexity
    def validate_chaudiere_biomasse(geste)
      error = []
      validate_chauffage(geste, error)
      error << "type_combustible_chaudiere_manquant" if geste[:type_combustible].blank? # buche, granulé, copeaux ...
      error << "type_chargement_manquant" if geste[:type_chargement].blank? # manuelle ou auto
      error << "type_silo_manquant" if geste[:type_silo].blank? # externe/interne, neuf/existant, Textile/maconner
      error << "contenance_silo_manquant" if geste[:contenance_silo].blank?
      error << "contenance_silo_trop_petit" if geste[:contenance_silo].present? && geste[:contenance_silo] < 225

      # TODO: V1 : Valeur EtAS :
      # - ≥ 77 % pour les chaudières ≤ 20 kW
      # - ≥ 79 % pour les chaudières supérieur à 20 kW (supérieur à 78% pour MaPrimeRenov' ?? TODO vérif)

      # Si label, pas besoin de vérifier les emissions
      unless geste[:label_flamme_verte]
        error << "emission_CO_chaudiere_manquant" if geste[:emission_CO].blank?
        # Emission monoxyde de carbone rapportée (CO) à 10% d’O2 (mg/Nm3)
        # TODO V1 ≤600mg/Nm3 pour manuelle et ≤400mg/Nm3 pour automatique)

        error << "emission_COG_chaudiere_manquant" if geste[:emission_COG].blank?
        # Emission de composés organiques volatiles (COG) (mg/Nm3) rapportée à 10% d’O2
        # TODO V1 :(≤ 20mg/Nm3 pour manuelle ≤16mg/Nm3 pour automatique)

        error << "emission_particule_chaudiere_manquant" if geste[:emission_particule].blank?
        # Emission de particules (mg/Nm3)
        # todo V1 : (≤40 pour manuelle et ≤30 pour automatique)

        error << "emission_Nox_chaudiere_manquant" if geste[:emission_Nox].blank?
        # Emissions d’oxydes d’azote (NOx) rapporté à 10% d’O2 (mg/Nm3)
        # TODO (≤200 pour les deux)

      end

      # Régulateur. TODO : A challenger si on met en V0 ?
      error << "marque_regulateur_manquant" if geste[:marque_regulateur].blank?
      error << "reference_regulateur_manquant" if geste[:reference_regulateur].blank?
      # TODO: V1 : Classe IV selon classification européenne
      error << "classe_regulateur_manquant" if geste[:classe_regulateur].blank?

      error
    end
    # rubocop:enable Metrics/PerceivedComplexity
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/AbcSize

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/MethodLength
    def validate_poele_insert(geste)
      error = []

      validate_chauffage(geste, error)

      error << "type_combustible_poele_manquant" if geste[:type_combustible].blank? # buche, granulé
      error << "rendement_energetique_manquant" if geste[:rendement_energetique].blank?

      # TODO: V1 : vérifier valeur ETAS (ɳs) (≥ 80% pour granulé, ≥ 65% pour bûches)

      unless geste[:label_flamme_verte]
        error << "emission_CO_poele_manquant" if geste[:emission_CO].blank?
        # Emission de monoxyde de carbone rapporté à 13% d’O2) (mg/Nm3)
        # TODO V1 : (≤1500 pour bûches ≤ 300 pour granulé)

        error << "emission_COG_poele_manquant" if geste[:emission_COG].blank?
        # Emission de composés organiques Volatile (COG) rapporté à 13% d’O2(mgC/Nm3)
        # TODO V1 : (≤120 si bûches ≤ 60 si granulé)

        error << "emission_particule_poele_manquant" if geste[:emission_particule].blank?
        # Emission de particules rapportée à 13% d’O2(mg/Nm3)
        # TODO V1 / (≤40 si bûches ≤ 30 pour granulé)

        error << "emission_Nox_poele_manquant" if geste[:emission_Nox].blank?
        # Emission d’oxydes d’azotes (NOx) rapporté à 13% d’O2 (mg/Nm3)
        # TODO V1 / (≤ 200 pour les deux)

      end

      error
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/AbcSize

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity
    def validate_systeme_solaire_combine(geste)
      error = []

      validate_chauffage(geste, error)
      error << "marque_capteurs_manquant" if geste[:marque_capteurs].blank?
      error << "reference_capteurs_manquant" if geste[:reference_capteurs].blank?
      error << "type_capteurs_manquant" if geste[:type_capteurs].blank?
      error << "surface_captage_manquant" if geste[:surface_captage].blank? # m2
      # Todo V1 : Vérifier valeur
      # ≥ 6m2 MPR
      # ≥ 8m2 CEE

      error << "productivite_capteurs_manquant" if geste[:productivite_capteurs].blank? # W/m2
      # TODO : Que CEE ? V1, vérifier valeur : ≥ 600 W/m2
      error << "volume_ballon_manquant" if geste[:volume_ballon].blank?
      # (peut être associé à plusieurs ballons)
      # >300L MPR
      # >400L CEE
      # Si ≤500L → classe efficacité C à minima(MPR uniquement ?)
      # TODO V1, vérifier valeur + certification (que CEE? CSTBat ou solar keymark ou equivalente)

      # TODO: V1 : profil de soutirage

      error << "energie_appoint_manquant" if geste[:energie_appoint].blank? # electricité, gaz...

      # TODO: V1 :valeur ETAS
      # ≥ 82% si EES de l’appoint séparé inférieur à 82 %
      # ≥ 90% si EES de l’appoint inférieur à 90 %
      # ≥ 98% si EES de l’appoint ≥ 90 % et inférieur à 98 %. Sinon supérieur d’au moins 5 points à l’EES de l’appoint.

      error
    end
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/AbcSize

    def validate_pac(geste)
      error = []

      validate_chauffage(geste, error)
      # air-eau, eau-eau, air-air, hybride -> TODO Verifier si besoin de l'indication sur le devis
      error << "type_pac_manquant" if geste[:type_pac].blank?
      error << "regime_temperature_manquant" if geste[:regime_temperature].blank? # basse, moyenne, haute
      error << "type_fluide_frigorigene_manquant" if geste[:type_fluide_frigorigene].blank? # R410A -  attention, celui ci va être restreint, R32 …

      # TODO: V1, verifier valeur ETAS :
      # ≥ 126% si basse T
      # ≥ 111% si Haute T

      error << "cop_manquant" if geste[:cop].blank? # TODO: V1 Check if SCOP is required too.

      error
    end
  end
end
