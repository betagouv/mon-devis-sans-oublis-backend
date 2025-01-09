# frozen_string_literal: true

module QuoteValidator
  # Validator for the Quote
  # rubocop:disable Metrics/ClassLength
  class Global < Base
    VERSION = "0.0.1"

    def validate!
      super do
        validate_admin
        validate_works
      end
    end

    # doit valider les mentions administratives du devis
    def validate_admin
      # mention devis présente ou non, quote[:mention_devis] est un boolean
      unless quote[:mention_devis] || quote[:devis].present?
        add_error("devis_manquant", category: "admin",
                                    type: "missing")
      end
      add_error("numero_devis_manquant", category: "admin", type: "missing") if quote[:numero_devis].blank?

      validate_dates
      validate_pro
      validate_client
      validate_rge
    end

    # date d'emission, date de pré-visite (CEE uniquement ?),
    # validité (par défaut 3 mois -> Juste un warning),
    # Date de début de chantier (CEE uniquement)
    # rubocop:disable Metrics/AbcSize
    def validate_dates
      # date_devis
      add_error("date_devis_manquant", category: "admin", type: "missing") if quote[:date_devis].blank?

      # date_debut_chantier
      date_chantier = quote[:date_chantier] || quote[:date_debut_chantier]
      add_error("date_chantier_manquant", category: "admin", type: "warning") if date_chantier.blank?

      # date_pre_visite
      add_error("date_pre_visite_manquant", category: "admin", type: "warning") if quote[:date_pre_visite].blank?

      # validite
      add_error("date_validite_manquant", category: "admin", type: "warning") unless quote[:validite]
    end
    # rubocop:enable Metrics/AbcSize

    # V0 on check la présence - attention devrait dépendre du geste, à terme,
    # on pourra utiliser une API pour vérifier la validité
    # Attention, souvent on a le logo mais rarement le numéro RGE.
    def validate_rge
      @pro = quote[:pro] ||= TrackingHash.new
      rge_labels = @pro[:labels]
      add_error("rge_manquant", category: "admin", type: "missing") if rge_labels.blank?
    end

    # doit valider les mentions administratives associées à l'artisan
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/PerceivedComplexity
    def validate_pro
      @pro = quote[:pro] ||= TrackingHash.new

      add_error("pro_raison_sociale_manquant", category: "admin", type: "missing") if @pro[:raison_sociale].blank?
      # on essaie de récupérer la forme juridique pendant l'anonymisation mais aussi avec le LLM.
      if @pro[:forme_juridique].blank? && quote[:pro_forme_juridique].blank?
        add_error("pro_forme_juridique_manquant", category: "admin", type: "missing")
      end
      add_error("tva_manquant", category: "admin", type: "missing") if @pro[:numero_tva].blank?
      # TODO: check format tva : FR et de 11 chiffres
      # (une clé informatique de 2 chiffres et le numéro SIREN à 9 chiffres de l'entreprise)

      # TODO: rajouter une condition si personne physique professionnelle et dans ce cas pas de SIRET nécessaire
      add_error("capital_manquant", category: "admin", type: "missing") if @pro[:capital].blank?
      add_error("siret_manquant", category: "admin", type: "missing") if @pro[:siret].blank?
      # beaucoup de confusion entre SIRET (14 chiffres pour identifier un etablissement)
      # et SIREN (9 chiffres pour identifier une entreprise)
      if @pro[:siret]&.gsub(/\s+/, "")&.length != 14 && @pro[:siret]&.length&.positive?
        add_error("siret_format_erreur", category: "admin",
                                         type: "wrong")
      end

      validate_pro_address
    end
    # rubocop:enable Metrics/PerceivedComplexity
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/AbcSize

    # doit valider les mentions administratives associées au client
    def validate_client
      @client = quote[:client] ||= TrackingHash.new

      add_error("client_prenom_manquant", category: "admin", type: "missing") if @client[:prenom].blank?
      add_error("client_nom_manquant", category: "admin", type: "missing") if @client[:nom].blank?

      validate_client_address
    end

    # vérifier la présence de l'adresse du client.
    # + Warning pour préciser que l'adresse de facturation = adresse de chantier si pas de présence
    def validate_client_address
      client_address = @client[:adresse]
      validate_address(client_address, "client")

      site_address = @client[:adresse_chantier]
      if site_address.blank?
        add_error("chantier_facturation_idem", category: "admin", type: "warning")
      else
        validate_address(site_address, "chantier")
      end
    end

    def validate_pro_address
      address = @pro[:adresse]
      validate_address(address, "pro")
    end

    # numéro, rue, cp, ville - si pas suffisant numéro de parcelle cadastrale. V0, on check juste la présence ?
    def validate_address(address, type)
      return if address.present?

      case type
      when "client"
        add_error("client_adresse_manquant", category: "admin", type: "missing")
      when "chantier" # ne devrait pas arriver, mais par la suite, faudrait vérifier la justesse de l'adresse
        add_error("chantier_adresse_manquant", category: "admin", type: "missing")
      when "pro"
        add_error("pro_adresse_manquant", category: "admin", type: "missing")
      end
    end

    # doit valider les critères techniques associés aux gestes présents dans le devis
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/MethodLength
    def validate_works
      isolation = Works::Isolation.new(quote, error_details:)
      menuiserie = Works::Menuiserie.new(quote, error_details:)
      chauffage = Works::Chauffage.new(quote, error_details:)
      eau_chaude = Works::EauChaude.new(quote, error_details:)
      ventilation = Works::Ventilation.new(quote, error_details:)

      gestes = quote[:gestes] || []
      gestes.each do |geste| # rubocop:disable Metrics/BlockLength
        case geste[:type]

        # ISOLATION
        when "isolation_thermique_par_exterieur_ITE"
          isolation.validate_isolation_ite(geste)
        when "isolation_comble_perdu", "isolation_combles_perdues"
          isolation.validate_isolation_combles(geste)
        when "isolation_rampants_toiture"
          isolation.validate_isolation_rampants(geste)
        when "isolation_toiture_terrasse"
          isolation.validate_isolation_toiture_terrasse(geste)
        when "isolation_thermique_par_interieur_ITI"
          isolation.validate_isolation_iti(geste)
        when "isolation_plancher_bas"
          isolation.validate_isolation_plancher_bas(geste)

        # MENUISERIEs
        when "menuiserie_fenetre"
          menuiserie.validate_menuiserie_fenetre(geste)
        when "menuiserie_fenetre_toit"
          menuiserie.validate_menuiserie_fenetre_toit(geste)
        when "menuiserie_porte"
          menuiserie.validate_menuiserie_porte(geste)
        when "menuiserie_volet_isolant"
          menuiserie.validate_menuiserie_volet_isolant(geste)

        # CHAUFFAGE
        when "chaudiere_biomasse"
          chauffage.validate_chaudiere_biomasse(geste)
        when "poele_insert"
          chauffage.validate_poele_insert(geste)
        when "systeme_solaire_combine"
          chauffage.validate_systeme_solaire_combine(geste)
        when "pac", "pac_air_eau", "pac_hybride", "pac_eau_eau"
          chauffage.validate_pac(geste)
        when "pac_air_air"
          chauffage.validate_pac_air_air(geste)

        # EAU CHAUDE SANITAIRE
        when "chauffe_eau_solaire_individuel"
          eau_chaude.validate_cesi(geste)
        when "chauffe_eau_thermo", "chauffe_eau_thermodynamique"
          eau_chaude.validate_chauffe_eau_thermodynamique(geste)

        # VENTILATION
        when "vmc_simple_flux"
          ventilation.validate_vmc_simple_flux(geste)
        when "vmc_double_flux"
          ventilation.validate_vmc_double_flux(geste)

        # DEPOSE CUVE A FIOUL

        # SYSTEME DE REGULATION

        # AUDIT ENERGETIQUE

        else
          e = NotImplementedError.new("Geste inconnu '#{geste[:type]}' is not listed")
          ErrorNotifier.notify(e)

          "geste_inconnu"
        end
      end
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/AbcSize

    def version
      self.class::VERSION
    end
  end
  # rubocop:enable Metrics/ClassLength
end
