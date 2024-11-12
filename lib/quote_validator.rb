# frozen_string_literal: true

# Validator for the Quote
class QuoteValidator
  attr_accessor :errors

  # @param [Hash] quote
  # quote is a hash with the following keys
  # - siret: [String] the SIRET number of the company
  def initialize(quote)
    @quote = quote
  end

  def validate!
    @errors = []
    @warning = []

    validate_admin
    validate_works

    valid?
  end

  # doit valider les mentions administratives du devis
  def validate_admin
    # mention devis présente ou non, quote[:devis] est un boolean
    @errors << "devis_manquant" if not @quote[:devis]
    @errors << "numero_devis_manquant" if not @quote[:numero_devis].blank?
    validate_dates
    validate_pro
    validate_client
    validate_rge
  end

  # date d'emission, date de pré-visite (CEE uniquement ?), validité (par défaut 3 mois -> Juste un warning), Date de début de chantier (CEE uniquement)
  def validate_dates
  end

  # V0 on check la présence - attention devrait dépendre du geste, à terme, on pourra utiliser une API pour vérifier la validité
  # Attention, souvent on a le logo mais rarement le numéro RGE. 
  def validate_rge
  end

  # doit valider les mentions administratives associées à l'artisan
  def validate_pro
    @pro = @quote[:pro]
    @errors << "pro_raison_sociale_manquant" if @pro[:raison_sociale].blank?
    @errors << "pro_forme_juridique_manquant" if @pro[:forme_juridique].blank?
    @errors << "tva_manquant" if @pro[:numero_tva].blank?
    # TODO check format tva : FR et de 11 chiffres (une clé informatique de 2 chiffres et le numéro SIREN à 9 chiffres de l'entreprise) 

    # TODO rajouter une condition si personne physique professionnelle et dans ce cas pas de SIRET nécessaire
    @errors << "capital_manquant" if @pro[:capital].blank?
    @errors << "siret_manquant" if @pro[:siret].blank?
    # beaucoup de confusion entre SIRET (14 chiffres pour identifier un etablissement) et SIREN (9 chiffres pour identifier une entreprise)
    @errors << "siret_format_erreur" if @pro[:siret].length != 14 && @pro[:siret].length > 0
    validate_pro_address

  end

  # doit valider les mentions administratives associées au client
  def validate_client
    @client = @quote[:client]
    @errors << "client_prenom_manquant" if @client[:prenom].blank?
    @errors << 'client_nom_manquant' if @client[:nom].blank?
    validate_client_address
  end

  # vérifier la présence de l'adresse du client. + Warning pour préciser que l'adresse de facturation = adresse de chantier si pas de présence
  def validate_client_address
    client_address = @client[:adresse]
    validate_address(client_address)

    site_address = @client[:adresse_chantier]
    if site_address.blank?
      @warning << "chantier_facturation_idem"
    else
      validate_address(site_address)
    end
  end

  def validate_pro_address
    address = @pro[:adresse]
    validate_address(address)
  end

  # numéro, rue, cp, ville - si pas suffisant numéro de parcelle cadastrale. V0, on check juste la présence ? 
  def validate_address(address)

  end

  # doit valider les critères techniques associés aux gestes présents dans le devis
  def validate_works
    works = @quote[:gestes]
    works.each do |geste|
      case geste[:type]


      # ISOLATION
      when 'isolation_mur_ite'
        validate_isolation_ite(geste)
      when 'isolation_combles_perdues'
        validate_isolation_combles(geste)
      when 'isolation_rampants-toiture'
        validate_isolation_rampants(geste)
      when 'isolation_toiture_terrasse'
        validate_isolation_toiture_terrasse(geste)
      when 'isolation_mur_iti'
        validate_isolation_iti(geste)
      when 'isolation_plancher_bas'
        validate_isolation_plancher_bas(geste)


      # MENUISERIEs
      when 'menuiserie_fenetre'
        validate_menuiserie_fenetre(geste)
      when 'menuiserie_fenetre_toit'
        validate_menuiserie_fenetre_toit(geste)
      when 'menuiserie_porte'
        validate_menuiserie_porte(geste)
      when 'menuiserie_volet_isolant'
        validate_menuiserie_volet_isolant(geste)

      when ''
        validate_(geste)
      else
        @errors << "geste_inconnu"
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
    error << "surface_manquant" if geste[:surface].blank? #TODO : check unité ? 
    error << "epaisseur_manquant" if geste[:epaisseur].blank? #TODO : check unité ? 
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



  #################################################
  ####              MENUISERIE                 ####
  #################################################
  
  # validation des critères communs à toutes les menuiseries 
  def validate_menuiserie(geste, error)
    error << "marque_manquant" if geste[:marque].blank?
    error << "reference_manquant" if geste[:reference].blank?
    error << "type_materiau_manquant" if geste[:type_materiau].blank? #bois, alu, pvc ...
    error << "type_vitrage_manquant" if geste[:type_vitrage].blank? #simple - double vitrage
    error << "type_pose_manquant" if geste[:type_pose].blank? #renovation ou depose totale
    error << "localisation_manquant" if geste[:localisation].blank?
    error << "position_paroie_manquant" if geste[:position_paroie].blank? # nu intérieur, nu extérieur, tunnel ... 

  end

  def validate_menuiserie_fenetre(geste)
    error = []

    validate_menuiserie(geste,error)
    error << "uw_manquant" if geste[:uw].blank?
    error << "sw_manquant" if geste[:sw].blank? 
    # V1, check valeurs : Uw ≤ 1,3 W/m².K et Sw ≥ 0,3 OU Uw ≤ 1,7 W/m².K et Sw ≥ 0,36

    errors << error
  end
  
  def validate_menuiserie_fenetre_toit(geste)
    error = []
    
    validate_menuiserie(geste,error)
    error << "uw_manquant" if geste[:uw].blank?
    error << "sw_manquant" if geste[:sw].blank? 
    # V1, check valeurs : (Uw ≤ 1,5 W/m².K et Sw ≤ 0,36 )

    errors << error
  end
  
  def validate_menuiserie_porte(geste)
    error = []
    
    validate_menuiserie(geste,error)
    error << "ud_manquant" if geste[:ud].blank? #TODO : Que CEE ? 
    #v1, check valeurs : Ud ≤ 1,7 W/m².K

    errors << error
  end
  
  def validate_menuiserie_volet_isolant(geste)
    error = []
    
    validate_menuiserie(geste,error)

    error << "deltaR_manquant" if geste[:deltaR].blank? #TODO: Que CEE ? 
    #v1, check valeurs :La résistance thermique additionnelle DeltaR (DeltaR ≥ 0,22 m².K/W)

    errors << error
  end


  #################################################
  ####              CHAUFFAGE                  ####
  #################################################


  #################################################
  ####         EAU CHAUDE SANITAIRE            ####
  #################################################


  #################################################
  ####             VENTILATION                 ####
  #################################################

  def valid?
    !@errors.nil? && @errors.empty?
  end
end
