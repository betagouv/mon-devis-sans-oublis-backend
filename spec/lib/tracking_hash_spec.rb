# frozen_string_literal: true

require "rails_helper"

RSpec.describe TrackingHash, type: :service do
  describe "#[]" do
    it "works like a Hash" do
      hash = described_class.new(a: 1)
      expect(hash[:a]).to eq 1
    end
  end

  describe "#keys_accessed" do
    it "returns the keys that have been accessed" do
      hash = described_class.new(a: 1, subhash: { b: 2 })
      hash[:a]
      hash[:subhash][:b]

      expect(hash.keys_accessed).to eq([:a, { subhash: [:b] }])
    end
  end
end
