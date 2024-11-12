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

      # CHAUFFAGE
      when 'chaudiere_biomasse'
        validate_chaudiere_biomasse(geste)
      when 'poele_insert'
        validate_poele_insert(geste)
      when 'systeme_solaire_combine'
        validate_systeme_solaire_combine(geste)
      when 'pac'
        validate_pac(geste)




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

  def validate_chauffage(geste, error)
    error << "puissance_manquant" if geste[:puissance].blank?
    error << "marque_manquant" if geste[:marque].blank?
    error << "reference_manquant" if geste[:reference].blank?
    error << "ETAS manquant" if geste[:ETAS].blank # en %

    @warning << "remplacement_chaudiere_condensation_manquant" if geste[:mention_remplacement].blank? #TODO à challenger
  end

  def validate_chaudiere_biomasse(geste)
    error = []
    validate_chauffage(geste,error)
    error << "type_combustible_manquant" if geste[:type_combustible].blank? # buche, granulé, coeaux ... 
    error << "type_chargement_manquant" if geste[:type_chargement].blank? #manuelle ou auto 
    error << "type_silo_manquant" if geste[:type_silo].blank? #externe/interne, neuf/existant, Textile/maconner
    error << "contenance_silo_manquant" if geste[:contenance_silo].blank?
    if !geste[:contenance_silo].blank? && geste[:contenance_silo] < 225
      error << "contenance_silo_trop_petit" 
    end

    # TODO V1 : Valeur EtAS : 
    # - ≥ 77 % pour les chaudières ≤ 20 kW
    # - ≥ 79 % pour les chaudières supérieur à 20 kW (supérieur à 78% pour MaPrimeRenov' ?? TODO vérif)

    #Si label, pas besoin de vérifier les emissions
    if !geste[:label_flamme_verte] 
      error << "emission_CO_manquant" if geste[:emission_CO].blank?
      # Emission monoxyde de carbone rapportée (CO) à 10% d’O2 (mg/Nm3) 
      # TODO V1 ≤600mg/Nm3 pour manuelle et ≤400mg/Nm3 pour automatique)

      error << "emission_COG_manquant" if geste[:emission_COG].blank?
      # Emission de composés organiques volatiles (COG) (mg/Nm3) rapportée à 10% d’O2 
      # TODO V1 :(≤ 20mg/Nm3 pour manuelle ≤16mg/Nm3 pour automatique)

      error << "emission_particule_manquant" if geste[:emission_particule].blank?
      # Emission de particules (mg/Nm3) 
      # todo V1 : (≤40 pour manuelle et ≤30 pour automatique)

      error << "emission_Nox_manquant" if geste[:emission_Nox].blank?
      # Emissions d’oxydes d’azote (NOx) rapporté à 10% d’O2 (mg/Nm3) 
      # TODO (≤200 pour les deux)

    end

    # Régulateur. TODO : A challenger si on met en V0 ? 
    error << "marque_regulateur_manquant" if geste[:marque_regulateur].blank?
    error << "reference_regulateur_manquant" if geste[:reference_regulateur].blank?
    error << "classe_regulateur_manquant" if geste[:classe_regulateur].blank? # TODO V1 : Classe IV selon classification européenne
  
    errors << error
  end

  def validate_poele_insert(geste)
    error = []

    validate_chauffage(geste,error)

    error << "type_combustible_manquant" if geste[:type_combustible].blank? # buche, granulé
    error << "rendement_energetique_manquant" if geste[:rendement_energetique].blank?

    #TODO V1 : vérifier valeur ETAS (ɳs) (≥ 80% pour granulé, ≥ 65% pour bûches)

    if !geste[:label_flamme_verte] 
      error << "emission_CO_manquant" if geste[:emission_CO].blank?
      # Emission de monoxyde de carbone rapporté à 13% d’O2) (mg/Nm3) 
      # TODO V1 : (≤1500 pour bûches ≤ 300 pour granulé)

      error << "emission_COG_manquant" if geste[:emission_COG].blank?
      # Emission de composés organiques Volatile (COG) rapporté à 13% d’O2(mgC/Nm3) 
      #TODO V1 : (≤120 si bûches ≤ 60 si granulé)

      error << "emission_particule_manquant" if geste[:emission_particule].blank?
      # Emission de particules rapportée à 13% d’O2(mg/Nm3) 
      #TODO V1 / (≤40 si bûches ≤ 30 pour granulé)

      error << "emission_Nox_manquant" if geste[:emission_Nox].blank?
      # Emission d’oxydes d’azotes (NOx) rapporté à 13% d’O2 (mg/Nm3) 
      #TODO V1 / (≤ 200 pour les deux)

    end

  
    errors << error
  end

  def validate_systeme_solaire_combine(geste)
    error = []

    validate_chauffage(geste,error)
    error << "marque_capteurs_manquant" if geste[:marque_capteurs].blank?
    error << "reference_capteurs_manquant" if geste[:reference_capteurs].blank?
    error << "type_capteurs_manquant" if geste[:type_capteurs].blank?
    error << "surface_captage_manquant" if geste[:surface_captage].blank? #m2
    #Todo V1 : Vérifier valeur
    # ≥ 6m2 MPR
    # ≥ 8m2 CEE

    error << "productivite_capteurs_manquant" if geste[:productivite_capteurs].blank? #W/m2
    #TODO : Que CEE ? V1, vérifier valeur : ≥ 600 W/m2
    error << "volume_ballon_manquant" if geste[:volume_ballon].blank? 
    # (peut être associé à plusieurs ballons)
    # >300L MPR
    # >400L CEE
    # Si ≤500L → classe efficacité C à minima(MPR uniquement ?)
    #TODO V1, vérifier valeur + certification (que CEE? CSTBat ou solar keymark ou equivalente)

    # TODO V1 : profil de soutirage 


    error << "energie_appoint_manquant" if geste[:energie_appoint].blank? # electricité, gaz... 

    # TODO V1 :valeur ETAS 
    # ≥ 82% si EES de l’appoint séparé inférieur à 82 %
    # ≥ 90% si EES de l’appoint inférieur à 90 %
    # ≥ 98% si EES de l’appoint ≥ 90 % et inférieur à 98 %. Sinon supérieur d’au moins 5 points à l’EES de l’appoint.

   
    errors << error
  end

  def validate_pac(geste)
    error = []

    validate_chauffage(geste,error)
    error << "type_pac_manquant" if geste[:type_pac].blank? # air-eau, eau-eau, air-air, hybride -> TODO Verifier si besoin de l'indication sur le devis
    error << "regime_temperature_manquant" if geste[:regime_temperature].blank? #basse, moyenne, haute
    error << "type_fluide_frigorigene_manquant" if geste[:type_fluide_frigorigene].blank? #R410A -  attention, celui ci va être restreint, R32 …

    #TODO V1, verifier valeur ETAS : 
    # ≥ 126% si basse T
    # ≥ 111% si Haute T

    error << "cop_manquant" if geste[:cop].blank? #TODO V1 Check if SCOP is required too.
  
    errors << error
  end

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
