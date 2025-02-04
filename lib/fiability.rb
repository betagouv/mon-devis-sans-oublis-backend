# frozen_string_literal: true

require "diff/lcs"

# (0...max_errors_count).to_a.sum do |index|
#   new_quote_check.validation_errors[index] == source_quote_check.expected_validation_errors[index] ? 0 : 1
# end

class Fiability
  def self.count_differences(array1, array2)
    changes = Diff::LCS.sdiff(array1, array2)
    changes.count { |change| change.action != "=" }
  end
end
