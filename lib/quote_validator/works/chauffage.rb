# frozen_string_literal: true

#################################################
####              CHAUFFAGE                  ####
#################################################

module QuoteValidator
  module Works
    # Validator for the Work
    class Chauffage < Base
      def validate_chauffage(geste)
        add_error("puissance_manquant", geste) if geste[:puissance].blank?
        add_error("marque_isolation_manquant", geste) if geste[:marque].blank?
        add_error("reference_isolation_manquant", geste) if geste[:reference].blank?
        add_error("etas_chauffage_manquant", geste) if geste[:ETAS].blank? # en %

        # TODO: à challenger
        return if geste[:remplacement_chaudiere_condensation]

        add_error("remplacement_chaudiere_condensation_manquant", geste)
      end

      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/CyclomaticComplexity
      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/PerceivedComplexity
      def validate_chaudiere_biomasse(geste)
        validate_chauffage(geste)

        # buche, granulé, copeaux ...
        add_error("type_combustible_chaudiere_manquant", geste) if geste[:type_combustible].blank?
        add_error("type_chargement_manquant", geste) if geste[:type_chargement].blank? # manuelle ou auto
        # externe/interne, neuf/existant, Textile/maconner
        add_error("type_silo_manquant", geste) if geste[:type_silo].blank?
        add_error("contenance_silo_manquant", geste) if geste[:contenance_silo].blank?
        add_error("contenance_silo_trop_petit", geste, type: "wrong") if geste[:contenance_silo].present? &&
                                                                         geste[:contenance_silo] < 225

        # TODO: V1 : Valeur EtAS :
        # - ≥ 77 % pour les chaudières ≤ 20 kW
        # - ≥ 79 % pour les chaudières supérieur à 20 kW (supérieur à 78% pour MaPrimeRenov' ?? TODO vérif)

        # Si label, pas besoin de vérifier les emissions
        unless geste[:label_flamme_verte]
          add_error("emission_CO_chaudiere_manquant", geste) if geste[:emission_CO].blank?
          # Emission monoxyde de carbone rapportée (CO) à 10% d’O2 (mg/Nm3)
          # TODO V1 ≤600mg/Nm3 pour manuelle et ≤400mg/Nm3 pour automatique)

          add_error("emission_COG_chaudiere_manquant", geste) if geste[:emission_COG].blank?
          # Emission de composés organiques volatiles (COG) (mg/Nm3) rapportée à 10% d’O2
          # TODO V1 :(≤ 20mg/Nm3 pour manuelle ≤16mg/Nm3 pour automatique)

          add_error("emission_particule_chaudiere_manquant", geste) if geste[:emission_particule].blank?
          # Emission de particules (mg/Nm3)
          # todo V1 : (≤40 pour manuelle et ≤30 pour automatique)

          add_error("emission_nox_chaudiere_manquant", geste) if geste[:emission_Nox].blank?
          # Emissions d’oxydes d’azote (NOx) rapporté à 10% d’O2 (mg/Nm3)
          # TODO (≤200 pour les deux)

        end

        # Régulateur. TODO : A challenger si on met en V0 ?
        add_error("marque_regulateur_manquant", geste) if geste[:marque_regulateur].blank?
        add_error("reference_regulateur_manquant", geste) if geste[:reference_regulateur].blank?
        # TODO: V1 : Classe IV selon classification européenne
        add_error("classe_regulateur_manquant", geste) if geste[:classe_regulateur].blank?
      end
      # rubocop:enable Metrics/PerceivedComplexity
      # rubocop:enable Metrics/MethodLength
      # rubocop:enable Metrics/CyclomaticComplexity
      # rubocop:enable Metrics/AbcSize

      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/CyclomaticComplexity
      def validate_poele_insert(geste)
        validate_chauffage(geste)

        add_error("type_combustible_poele_manquant", geste) if geste[:type_combustible].blank? # buche, granulé
        add_error("rendement_energetique_manquant", geste) if geste[:rendement_energetique].blank?

        # TODO: V1 : vérifier valeur ETAS (ɳs) (≥ 80% pour granulé, ≥ 65% pour bûches)

        return if geste[:label_flamme_verte]

        add_error("emission_CO_poele_manquant", geste) if geste[:emission_CO].blank?
        # Emission de monoxyde de carbone rapporté à 13% d’O2) (mg/Nm3)
        # TODO V1 : (≤1500 pour bûches ≤ 300 pour granulé)

        add_error("emission_COG_poele_manquant", geste) if geste[:emission_COG].blank?
        # Emission de composés organiques Volatile (COG) rapporté à 13% d’O2(mgC/Nm3)
        # TODO V1 : (≤120 si bûches ≤ 60 si granulé)

        add_error("emission_particule_poele_manquant", geste) if geste[:emission_particule].blank?
        # Emission de particules rapportée à 13% d’O2(mg/Nm3)
        # TODO V1 / (≤40 si bûches ≤ 30 pour granulé)

        add_error("emission_nox_poele_manquant", geste) if geste[:emission_Nox].blank?
        # Emission d’oxydes d’azotes (NOx) rapporté à 13% d’O2 (mg/Nm3)
        # TODO V1 / (≤ 200 pour les deux)
      end
      # rubocop:enable Metrics/CyclomaticComplexity
      # rubocop:enable Metrics/AbcSize

      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/CyclomaticComplexity
      def validate_systeme_solaire_combine(geste)
        validate_chauffage(geste)

        add_error("marque_capteurs_manquant", geste) if geste[:marque_capteurs].blank?
        add_error("reference_capteurs_manquant", geste) if geste[:reference_capteurs].blank?
        add_error("type_capteurs_manquant", geste) if geste[:type_capteurs].blank?
        add_error("surface_captage_manquant", geste) if geste[:surface_captage].blank? # m2
        # Todo V1 : Vérifier valeur
        # ≥ 6m2 MPR
        # ≥ 8m2 CEE

        add_error("productivite_capteurs_manquant", geste) if geste[:productivite_capteurs].blank? # W/m2
        # TODO : Que CEE ? V1, vérifier valeur : ≥ 600 W/m2
        add_error("volume_ballon_manquant", geste) if geste[:volume_ballon].blank?
        # (peut être associé à plusieurs ballons)
        # >300L MPR
        # >400L CEE
        # Si ≤500L → classe efficacité C à minima(MPR uniquement ?)
        # TODO V1, vérifier valeur + certification (que CEE? CSTBat ou solar keymark ou equivalente)

        # TODO: V1 : profil de soutirage

        add_error("energie_appoint_manquant", geste) if geste[:energie_appoint].blank? # electricité, gaz...

        # TODO: V1 :valeur ETAS
        # ≥ 82% si EES de l’appoint séparé inférieur à 82 %
        # ≥ 90% si EES de l’appoint inférieur à 90 %
        # ≥ 98% si EES de l’appoint ≥ 90 % et inférieur à 98 %. Sinon supérieur d’au moins 5 points à l’EES de l’appoint
      end
      # rubocop:enable Metrics/CyclomaticComplexity
      # rubocop:enable Metrics/AbcSize

      def validate_pac(geste)
        validate_chauffage(geste)

        # air-eau, eau-eau, air-air, hybride -> TODO Verifier si besoin de l'indication sur le devis
        add_error("type_pac_manquant", geste) if geste[:type_pac].blank?
        add_error("regime_temperature_manquant", geste) if geste[:regime_temperature].blank? # basse, moyenne, haute
        # R410A -  attention, celui ci va être restreint, R32 …
        add_error("type_fluide_frigorigene_manquant", geste) if geste[:type_fluide_frigorigene].blank?

        # TODO: V1, verifier valeur ETAS :
        # ≥ 126% si basse T
        # ≥ 111% si Haute T

        add_error("cop_chauffage_manquant", geste) if geste[:COP].blank? # TODO: V1 Check if SCOP is required too.
      end

      protected

      def add_error(code, geste, type: "missing")
        super(code,
                  type:,
                  category: "gestes",
                  provided_value: geste[:intitule])
      end
    end
  end
end
