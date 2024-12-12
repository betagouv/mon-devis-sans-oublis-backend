# frozen_string_literal: true

require "swagger_helper"

describe "Devis API" do
  path "/quote_checks" do
    # TODO: i18n?
    post "Téléverser un devis" do
      tags "Devis"
      # TODO: security [ basic_auth: [] ]
      consumes "multipart/form-data"
      produces "application/json"

      parameter name: :quote_check, in: :formData, schema: {
        type: :object,
        properties: {
          file: {
            type: :string,
            format: :binary
          },
          profile: { "$ref" => "#/components/schemas/profile" }
        },
        required: %w[file profile]
      }

      # See skip below
      # consumes 'application/x-www-form-urlencoded'

      # parameter name: :quote_check, in: :body, schema: {
      #   type: :object,
      #   properties: {
      #     file: {
      #       type: :string,
      #       format: :binary
      #     },
      #     profile: { "$ref" => "#/components/schemas/profile" }
      #   },
      #   required: %w[file profile]
      # }
      # parameter name: :file, in: :formData, schema: {
      #   type: :string,
      #   format: :binary
      # }, required: true
      # parameter name: :profile, in: :formData, schema: {
      #   "$ref" => "#/components/schemas/profile"
      # }, required: true

      let(:quote_check) { { file: file, profile: profile } }

      response "201", "Devis téléversé" do
        schema "$ref" => "#/components/schemas/quote_check"
        description "Au retour le devis a été téléversé avec succès.
Mais vérifiez selon le statut si le devis a été déjà analysé ou non.
Il peut contenir des erreurs dès le téléversement.
Si le statut est 'pending', cela signifie que l'analyse est encore en cours.
Et qu'il faut boucler sur l'appel /quote_check/:id pour récupérer le devis à jour.".gsub("\n", "<br>")

        let(:file) { fixture_file_upload("quote_files/Devis_test.pdf") }
        let(:profile) { "artisan" }

        pending "fix why quote_check params are not sent"
        # run_test!
      end

      response "422", "invalid request" do
        let(:file) { fixture_file_upload("quote_files/Devis_test.pdf") }
        let(:profile) { "blabla" }

        run_test!
      end
    end
  end

  path "/quote_checks/{id}" do
    get "Récupérer un Devis" do
      tags "Devis"
      consumes "application/json"
      produces "application/json"
      parameter name: :id, in: :path, type: :string, required: true

      response "200", "Devis trouvé" do
        schema "$ref" => "#/components/schemas/quote_check"

        let(:id) { create(:quote_check).id }

        run_test!
      end

      response "404", "Devis non trouvé" do
        let(:id) { SecureRandom.uuid }

        run_test!
      end
    end
  end
end
