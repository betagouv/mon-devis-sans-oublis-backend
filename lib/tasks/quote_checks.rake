# frozen_string_literal: true

namespace :quote_checks do
  desc "Create a QuoteCheck against a local file"
  task :create, [:file_path] => :environment do |_t, args|
    file_path = args[:file_path]
    puts "Error: File does not exist. Please check the path and try again." unless File.exist?(file_path)

    file = File.open(file_path)
    filename = File.basename(file_path)

    quote_check = QuoteCheckService.new(
      file, filename, "artisan"
    ).check

    puts JSON.pretty_generate(quote_check.attributes)
    puts "QuoteCheck created with id: #{quote_check.id}"
  end
end
