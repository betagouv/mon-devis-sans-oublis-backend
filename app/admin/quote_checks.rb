# frozen_string_literal: true

ActiveAdmin.register QuoteCheck do # rubocop:disable Metrics/BlockLength
  actions :index, :show

  config.filters = false
  config.sort_order = "created_at_desc"

  index do # rubocop:disable Metrics/BlockLength
    id_column do
      link_to "Devis #{it.id}", admin_quote_check_path(it)
    end

    column "Nom de fichier" do
      link_to it.filename, view_file_admin_quote_file_path(it.file, format: it.file.extension),
              target: "_blank", rel: "noopener"
    end

    column "Correction" do
      link_to "Devis #{it.id}", it.frontend_webapp_url
    end

    column "Gestes demandés" do
      "SOON" # TODO: Back Office
    end

    column "Gestes détectés" do
      it.read_attributes&.dig("gestes")&.map { it["type"] }&.uniq&.join("\n")
    end

    column "Aides demandées" do
      "SOON" # TODO: Back Office
    end

    column "Nb erreurs" do
      it.validation_errors&.count
    end

    column "Présence d’un feedback ?" do
      it.feedbacks.any?
    end

    column "Date upload" do
      it.file.created_at
    end

    column "Persona", :profile

    column "Nb de token", &:tokens_count

    actions defaults: false do
      link_to "Voir le détail", admin_quote_check_path(it), class: "button"
    end
  end

  show do # rubocop:disable Metrics/BlockLength
    attributes_table do
      row "Nom de fichier" do
        link_to resource.filename, view_file_admin_quote_file_path(resource.file, format: resource.file.extension),
                target: "_blank", rel: "noopener"
      end

      row :tokens_count, "Nb de token"
      row :profile, label: "Persona"

      row "Gestes demandés" do
        "SOON" # TODO: Back Office
      end

      row "Gestes détectés" do
        it.read_attributes&.dig("gestes")&.map { it["type"] }&.uniq&.join("\n")
      end

      row "Aides demandées" do
        "SOON" # TODO: Back Office
      end

      row "Correction" do
        link_to "Devis #{it.id}", it.frontend_webapp_url
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

      tab "Attributs récupérés" do
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

      tab "Texte Anonymisé" do
        pre resource.anonymised_text
      end

      tab "Texte brut" do
        pre resource.text
      end
    end
  end
end
