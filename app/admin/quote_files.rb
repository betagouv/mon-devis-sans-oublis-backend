# frozen_string_literal: true

ActiveAdmin.register QuoteFile do
  actions :index, :view_file

  config.filters = false
  config.sort_order = "created_at_desc"

  member_action :view_file, method: :get do
    quote_file = QuoteFile.find(params[:id])

    send_data quote_file.file.download,
              filename: quote_file.filename,
              type: quote_file.content_type,
              disposition: params[:disposition] || "inline"
  end

  index do
    id_column

    column :filename do
      link_to it.filename, view_file_admin_quote_file_path(it, format: it.file.extension),
              target: "_blank", rel: "noopener"
    end
    column :content_type
    column :created_at

    actions defaults: true do
      link_to "Voir le fichier", view_file_admin_quote_file_path(it, format: it.file.extension),
              class: "button", target: "_blank", rel: "noopener"
    end
  end
end
