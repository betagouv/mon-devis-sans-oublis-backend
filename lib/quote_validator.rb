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
  end

  def valid?
    !@errors.nil? && @errors.empty?
  end
end
