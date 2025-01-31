# frozen_string_literal: true

namespace :quote_checks do # rubocop:disable Metrics/BlockLength
  desc "Create a QuoteCheck against local file(s) or by diretory"
  task :create, [:file_path] => :environment do |_t, args|
    file_path = args[:file_path]

    if File.directory?(file_path)
      Dir.foreach(file_path) do |entry|
        sub_file_path = File.join(file_path, entry)
        next unless File.file?(sub_file_path) && entry != ".DS_Store"

        Rake::Task["quote_checks:create"].reenable
        Rake::Task["quote_checks:create"].invoke(sub_file_path)
      end
    else
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

  desc "Run Fiability checks on flagged QuoteChecks"
  task fiability: :environment do |_t, _args|
    # Anonymous temporary class
    class QuoteCheckToTest < QuoteCheck # rubocop:disable Lint/ConstantDefinitionInBlock
      establish_connection :test_source

      default_scope { with_expected_value }

      def readonly?
        true
      end
    end

    puts "Found QuoteCheckToTest #{QuoteCheckToTest.count}"
  end
end
