# frozen_string_literal: true

ActiveAdmin.register QuoteCheck do # rubocop:disable Metrics/BlockLength
  actions :index, :show

  config.filters = false

  index do
    column "Nom de fichier" do |quote_check| # rubocop:disable Style/SymbolProc
      quote_check.filename
      # TODO: add link to file
      # link_to "File ##{quote_check.filename}", admin_file_path(quote_check.file_id) if quote_check.filename
    end

    column "Correction" do |quote_check|
      link_to "Devis #{quote_check.id}", quote_check.frontend_webapp_url
    end

    column "Gestes" do |quote_check|
      quote_check.read_attributes&.fetch("gestes")&.map { it["type"] }&.uniq&.join("\n")
    end

    column "Aides demandées" do |quote_check|
      # TODO
    end

    column "Nb erreurs" do |quote_check|
      quote_check.validation_errors&.count
    end

    column "Présence d’un feedback ?" do |quote_check|
      quote_check.feedbacks.any? ? "Oui" : "Non"
    end

    column "Date upload" do
      it.file.created_at.strftime("%d/%m/%Y %H:%M")
    end

    column "Persona", :profile

    column "Nb de token", &:tokens_count

    actions defaults: false do |quote_check|
      link_to "Voir le détail", admin_quote_check_path(quote_check), class: "button"
    end
  end
end
