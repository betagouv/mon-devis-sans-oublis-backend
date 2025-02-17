# frozen_string_literal: true

def geste_errors(quote_check, geste_index)
  geste_id = QuoteValidator::Base.geste_index(
    quote_check.id, geste_index
  )
  quote_check.validation_error_details&.select { |error| error["geste_id"] == geste_id }
end

# rubocop:disable Rails/I18nLocaleTexts
ActiveAdmin.register QuoteCheck do # rubocop:disable Metrics/BlockLength
  actions :index, :show, :edit, :update

  permit_params :expected_validation_errors

  includes :file, :feedbacks

  config.filters = false
  config.sort_order = "created_at_desc"

  scope "tous", :all, default: true
  scope "avec valeurs test", :with_expected_value
  scope "fichier en erreur", :with_file_error
  scope "devis avec corrections", :with_edits

  controller do
    def update # rubocop:disable Metrics/MethodLength
      quote_check = resource

      begin
        # TODO: Find a proper way to parse JSON and reuse super
        quote_check.expected_validation_errors = if params[:quote_check][:expected_validation_errors].presence
                                                   JSON.parse(params[:quote_check][:expected_validation_errors])
                                                 end
      rescue JSON::ParserError
        redirect_to edit_admin_quote_check_path, alert: "Invalid JSON format" and return
      end

      if quote_check.save
        redirect_to admin_quote_check_path(quote_check), notice: "Quote check updated successfully"
      else
        render :edit, status: :unprocessable_entity
      end
    end
  end

  member_action :recheck, method: :post do
    quote_check = QuoteCheck.find(params[:id])

    if quote_check.recheckable?
      QuoteCheckCheckJob.perform_later(quote_check.id)
      flash[:success] = "Le devis est en cours de retraitement."
    else
      flash[:error] = "Le devis ne peut pas être retraité."
    end

    redirect_to admin_quote_check_path(quote_check)
  end

  action_item :recheck, only: :show do
    link_to "Re-vérifier à nouveau", recheck_admin_quote_check_path(resource), method: :post if resource.recheckable?
  end

  index do # rubocop:disable Metrics/BlockLength
    id_column do
      link_to "Devis #{it.id}", admin_quote_check_path(it)
    end

    column "Nom de fichier" do
      if it.file
        link_to it.filename, view_file_admin_quote_file_path(it.file, format: it.file.extension),
                target: "_blank", rel: "noopener"
      end
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

    column "Présence feedback ?" do
      it.feedbacks.any?
    end

    column "Présence commentaire ?" do
      it.comment.present?
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
        if resource.file
          link_to resource.filename, view_file_admin_quote_file_path(resource.file, format: resource.file.extension),
                  target: "_blank", rel: "noopener"
        end
      end

      row "Date soumission" do
        resource.started_at
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

      row "Nb erreurs" do
        it.validation_errors&.count
      end

      row "Correction" do
        link_to "Devis #{it.id}", it.frontend_webapp_url,
                target: "_blank", rel: "noopener"
      end

      row :comment, label: "Commentaire"

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

      row "expected_validation_errors" do
        pre JSON.pretty_generate(resource.expected_validation_errors) if resource.expected_validation_errors
      end
    end

    tabs do # rubocop:disable Metrics/BlockLength
      if resource.feedbacks.any?
        tab "Feedbacks" do
          table do
            thead do
              tr do
                th "Courriel"
                th "Note (globale)"
                th "Ligne en erreur dans devis (si feedback spécifique)"
                th "Commentaire"
              end
            end
            tbody do
              resource.feedbacks.each do |feedback|
                tr do
                  td feedback.email
                  td feedback.rating
                  td feedback.provided_value
                  td feedback.comment
                end
              end
            end
          end
        end
      end

      tab "Attributs détectés" do # rubocop:disable Metrics/BlockLength
        panel "Gestes" do # rubocop:disable Metrics/BlockLength
          gestes = resource.read_attributes&.dig("gestes")
          if gestes&.any?
            table_for gestes do # rubocop:disable Metrics/BlockLength
              column "Type" do |geste|
                geste.fetch("type")
              end
              column "Attributs" do |geste|
                pre JSON.pretty_generate(geste)
              end
              column "Erreur(s) et correction(s)" do |geste|
                geste_errors = geste_errors(resource, gestes.index(geste))

                if geste_errors&.any?
                  content_tag(:ul) do
                    geste_errors.map do
                      content = "#{it.fetch('code')} : #{it.fetch('title')} #{it.fetch('id')}"

                      edit = resource.validation_error_edits&.dig(it.fetch("id"))
                      if edit
                        deletetion_reason = edit["reason"]
                        if deletetion_reason # rubocop:disable Metrics/BlockNesting
                          deletetion_reason = I18n.t(
                            "quote_checks.validation_error_detail_deletion_reasons.#{deletetion_reason}",
                            fallback: deletetion_reason
                          )
                        end

                        content = safe_join([
                                              content,
                                              content_tag(:br),
                                              content_tag(:strong,
                                                          ["\nSupprimée", deletetion_reason].compact.join(" : "))
                                            ])
                      end

                      concat(content_tag(:li, content))
                    end
                  end
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

      tab "1. Texte brut" do
        pre resource.text
      end

      tab "2. Données privées via méthode naïve hors ligne" do
        pre JSON.pretty_generate(resource.naive_attributes)
      end

      tab "3. Données privées et Attributs via par Albert (Gouv)" do
        pre JSON.pretty_generate(resource.private_data_qa_attributes)

        h1 "Résultat technique brut"
        pre JSON.pretty_generate(resource.private_data_qa_result)
      end

      tab "4. Texte Anonymisé" do
        pre resource.anonymised_text
      end

      tab "5. Attributs via par Mistral" do
        pre JSON.pretty_generate(resource.qa_attributes)

        h1 "Résultat technique brut"
        pre JSON.pretty_generate(resource.qa_result)
      end

      tab "6. Retour API pour frontend" do
        pre JSON.pretty_generate(
          QuoteCheckSerializer.new(resource).as_json
        )
      end
    end
  end

  form do |f|
    f.inputs "Quote Check Details" do
      f.input :expected_validation_errors,
              input_html: {
                value: JSON.pretty_generate(
                  f.object.expected_validation_errors.presence ||
                  f.object.validation_errors
                )
              }
    end
    f.actions
  end
end
# rubocop:enable Rails/I18nLocaleTexts
