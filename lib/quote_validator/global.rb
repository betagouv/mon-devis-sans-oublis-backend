# frozen_string_literal: true

# Validator for the Quote
module QuoteValidator
  class Global < Base
    def validate!
      @errors = []
      @warnings = []

      
      @errors << isolation.errors
      @warnings << isolation.warnings

      validate_admin
      validate_works

      valid?
    end

    # doit valider les mentions administratives du devis
    def validate_admin
      # mention devis présente ou non, quote[:devis] est un boolean
      @errors << "devis_manquant" unless @quote[:devis]
      @errors << "numero_devis_manquant" if @quote[:numero_devis].present?
      validate_dates
      validate_pro
      validate_client
      validate_rge
    end

    # date d'emission, date de pré-visite (CEE uniquement ?), validité (par défaut 3 mois -> Juste un warning), Date de début de chantier (CEE uniquement)
    def validate_dates; end

    # V0 on check la présence - attention devrait dépendre du geste, à terme, on pourra utiliser une API pour vérifier la validité
    # Attention, souvent on a le logo mais rarement le numéro RGE.
    def validate_rge; end

    # doit valider les mentions administratives associées à l'artisan
    def validate_pro
      @pro = @quote[:pro] || {}
      @errors << "pro_raison_sociale_manquant" if @pro[:raison_sociale].blank?
      @errors << "pro_forme_juridique_manquant" if @pro[:forme_juridique].blank?
      @errors << "tva_manquant" if @pro[:numero_tva].blank?
      # TODO: check format tva : FR et de 11 chiffres (une clé informatique de 2 chiffres et le numéro SIREN à 9 chiffres de l'entreprise)

      # TODO: rajouter une condition si personne physique professionnelle et dans ce cas pas de SIRET nécessaire
      @errors << "capital_manquant" if @pro[:capital].blank?
      @errors << "siret_manquant" if @pro[:siret].blank?
      # beaucoup de confusion entre SIRET (14 chiffres pour identifier un etablissement) et SIREN (9 chiffres pour identifier une entreprise)
      @errors << "siret_format_erreur" if @pro[:siret]&.length != 14 && @pro[:siret]&.length&.positive?
      validate_pro_address
    end

    # doit valider les mentions administratives associées au client
    def validate_client
      @client = @quote[:client] || {}
      @errors << "client_prenom_manquant" if @client[:prenom].blank?
      @errors << "client_nom_manquant" if @client[:nom].blank?
      validate_client_address
    end

    # vérifier la présence de l'adresse du client. + Warning pour préciser que l'adresse de facturation = adresse de chantier si pas de présence
    def validate_client_address
      client_address = @client[:adresse]
      validate_address(client_address)

      site_address = @client[:adresse_chantier]
      if site_address.blank?
        @warnings << "chantier_facturation_idem"
      else
        validate_address(site_address)
      end
    end

    def validate_pro_address
      address = @pro[:adresse]
      validate_address(address)
    end

    # numéro, rue, cp, ville - si pas suffisant numéro de parcelle cadastrale. V0, on check juste la présence ?
    def validate_address(address); end

    # doit valider les critères techniques associés aux gestes présents dans le devis
    def validate_works
      works = @quote[:gestes] || []
      isolation = Isolation.new(@quote)
      menuiserie = Menuiserie.new(@quote)
      chauffage = Chauffage.new(@quote)
      eau_chaude = EauChaude.new(@quote)
      ventilation = Ventilation.new(@quote)

      works.each do |geste|
        case geste[:type]

        # ISOLATION
        when "isolation_mur_ite"
          @errors << isolation.validate_isolation_ite(geste)
        when "isolation_combles_perdues"
          @errors << isolation.validate_isolation_combles(geste)
        when "isolation_rampants-toiture"
          @errors << isolation.validate_isolation_rampants(geste)
        when "isolation_toiture_terrasse"
          @errors << isolation.validate_isolation_toiture_terrasse(geste)
        when "isolation_mur_iti"
          @errors << isolation.validate_isolation_iti(geste)
        when "isolation_plancher_bas"
          @errors << isolation.validate_isolation_plancher_bas(geste)

        # MENUISERIEs
        when "menuiserie_fenetre"
          @errors << menuiserie.validate_menuiserie_fenetre(geste)
        when "menuiserie_fenetre_toit"
          @errors << menuiserie.validate_menuiserie_fenetre_toit(geste)
        when "menuiserie_porte"
          @errors << menuiserie.validate_menuiserie_porte(geste)
        when "menuiserie_volet_isolant"
          @errors << menuiserie.validate_menuiserie_volet_isolant(geste)

        # CHAUFFAGE
        when "chaudiere_biomasse"
          @errors << chauffage.validate_chaudiere_biomasse(geste)
        when "poele_insert"
          @errors << chauffage.validate_poele_insert(geste)
        when "systeme_solaire_combine"
          @errors << chauffage.validate_systeme_solaire_combine(geste)
        when "pac"
          @errors << chauffage.validate_pac(geste)

        # EAU CHAUDE SANITAIRE
        when "chauffe_eau_solaire_individuel"
          @errors << eau_chaude.validate_cesi(geste)
        when "chauffe_eau_thermodynamique"
          @errors << eau_chaude.validate_chauffe_eau_thermodynamique(geste)

        # VENTILATION
        when "vmc_simple_flux"
          @errors << ventilation.validate_vmc_simple_flux(geste)
        when "vmc_double_flux"
          @errors << ventilation.validate_vmc_double_flux(geste)

        # DEPOSE CUVE A FIOUL

        # SYSTEME DE REGULATION

        # AUDIT ENERGETIQUE

        else
          @errors << "geste_inconnu"
        end
      end
    end

    
  end
end
