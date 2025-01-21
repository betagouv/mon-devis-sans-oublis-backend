# frozen_string_literal: true

ActiveAdmin.register QuoteCheck do # rubocop:disable Metrics/BlockLength
  actions :index, :show

  includes :file, :feedbacks

  config.filters = false
  config.sort_order = "created_at_desc"

  member_action :recheck, method: :post do
    quote_check = QuoteCheck.find(params[:id])

    QuoteCheckCheckJob.perform_later(quote_check.id)

    flash[:success] = "Le devis est en cours de retraitement." # rubocop:disable Rails/I18nLocaleTexts
    redirect_to admin_quote_check_path(quote_check)
  end

  action_item :recheck, only: :show do
    unless resource.status == "pending"
      link_to "Re-vérifier à nouveau", recheck_admin_quote_check_path(resource), method: :post
    end
  end

  index do # rubocop:disable Metrics/BlockLength
    id_column do
      link_to "Devis #{it.id}", admin_quote_check_path(it)
    end

    column "Nom de fichier" do
      link_to it.filename, view_file_admin_quote_file_path(it.file, format: it.file.extension),
              target: "_blank", rel: "noopener"
    end

    column "Correction" do
      link_to "Devis #{it.id}", it.frontend_webapp_url,
              target: "_blank", rel: "noopener"
    end

    column "Gestes demandés" do
      it.metadata&.dig("gestes")&.join("\n")
    end

    column "Gestes détectés" do
      it.read_attributes&.dig("gestes")&.map { it["type"] }&.uniq&.join("\n")
    end

    column "Aides demandées" do
      it.metadata&.dig("aides")&.join("\n")
    end

    column "Nb erreurs" do
      it.validation_errors&.count
    end

    column "Présence d’un feedback ?" do
      it.feedbacks.any?
    end

    column "Date soumission" do
      it.started_at
    end

    column "Persona", :profile
    column "Nb de token" do
      number_with_delimiter(it.tokens_count, delimiter: " ")
    end
    column "temps traitement" do
      "#{it.processing_time.ceil(1)}s" if it.processing_time
    end

    actions defaults: false do
      link_to "Voir le détail", admin_quote_check_path(it), class: "button"
    end
  end

  show do # rubocop:disable Metrics/BlockLength
    attributes_table do # rubocop:disable Metrics/BlockLength
      row "Nom de fichier" do
        link_to resource.filename, view_file_admin_quote_file_path(resource.file, format: resource.file.extension),
                target: "_blank", rel: "noopener"
      end

      row :tokens_count, "Nb de token" do
        number_with_delimiter(it.tokens_count, delimiter: " ")
      end
      row :profile, label: "Persona"

      row "Gestes demandés" do
        it.metadata&.dig("gestes")&.join("\n")
      end

      row "Gestes détectés" do
        it.read_attributes&.dig("gestes")&.map { it["type"] }&.uniq&.join("\n")
      end

      row "Aides demandées" do
        it.metadata&.dig("aides")&.join("\n")
      end

      row "Correction" do
        link_to "Devis #{it.id}", it.frontend_webapp_url,
                target: "_blank", rel: "noopener"
      end

      row "temps traitement" do
        "#{resource.processing_time.ceil(1)}s" if resource.processing_time
      end

      row "version application" do
        if resource.application_version && resource.application_version != "unknown"
          link_to resource.application_version,
                  "https://github.com/betagouv/mon-devis-sans-oublis-backend/tree/#{resource.application_version}",
                  target: "_blank", rel: "noopener"
        end
      end
    end

    tabs do # rubocop:disable Metrics/BlockLength
      if resource.feedbacks.any?
        tab "Feedbacks" do
          table do
            thead do
              tr do
                th "Note (globale)"
                th "Ligne en erreur dans devis (si feedback spécifique)"
                th "Commentaire"
              end
            end
            tbody do
              resource.feedbacks.each do |feedback|
                tr do
                  td feedback.rating
                  td feedback.provided_value
                  td feedback.comment
                end
              end
            end
          end
        end
      end

      tab "Attributs détectés" do
        panel "Gestes" do
          if (gestes = resource.read_attributes&.dig("gestes")&.index_by { it["type"] })
            attributes_table_for gestes do
              gestes.each do |type, geste|
                row type.to_s.humanize do
                  pre JSON.pretty_generate(geste)
                end
              end
            end
          end
        end

        panel "Administratifs (hors données ADEME)" do
          if (attributes = resource.read_attributes&.except("extended_data", "gestes"))
            attributes_table_for attributes do
              attributes.each do |key, value|
                row key.to_s.humanize do
                  simplest_value = value.is_a?(Array) && value.size == 1 ? value.first : value
                  if simplest_value.is_a?(Hash) || simplest_value.is_a?(Array)
                    pre JSON.pretty_generate(simplest_value)
                  else
                    simplest_value
                  end
                end
              end
            end
          end
        end
      end

      tab "Attributs via par Mistral" do
        pre JSON.pretty_generate(resource.qa_attributes)
      end

      tab "Attributs via par Albert" do
        pre JSON.pretty_generate(resource.private_data_qa_attributes)

        h1 "Résultat brut"
        pre JSON.pretty_generate(resource.private_data_qa_result)
      end

      tab "Attributs via méthode naïve hors ligne privé" do
        pre JSON.pretty_generate(resource.naive_attributes)
      end

      tab "Texte Anonymisé" do
        pre resource.anonymised_text
      end

      tab "Texte brut" do
        pre resource.text
      end

      tab "Retour API" do
        pre JSON.pretty_generate(Api::V1::QuoteChecksController.quote_check_json(resource))
      end
    end
  end
end
