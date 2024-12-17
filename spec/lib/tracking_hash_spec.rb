# frozen_string_literal: true

require "rails_helper"

RSpec.describe TrackingHash, type: :service do
  describe "#[]" do
    it "works like a Hash" do
      hash = described_class.new(a: 1)
      expect(hash[:a]).to eq 1
    end

    # rubocop:disable RSpec/MultipleExpectations
    it "works like an indifferent Hash" do
      expect(described_class.new(a: 1)["a"]).to eq 1
      expect(described_class.new("a" => 1)[:a]).to eq 1
    end
    # rubocop:enable RSpec/MultipleExpectations

    context "with an empty Hash and unknown key" do
      it "works as usual" do
        expect(described_class.new[:unknown_key]).to be_nil
      end
    end
  end

  describe "#dig" do
    context "with an empty Hash" do
      it "works as usual" do
        hash = described_class.new
        expect(hash.dig(nil)).to be_nil # rubocop:disable Style/SingleArgumentDig
      end
    end

    # rubocop:disable RSpec/MultipleExpectations
    it "works like with quotes and symbols" do
      hash = described_class.new(subhash_symbol: [{ "key" => 1 }])
      expect(hash.dig("subhash_symbol", 0, "key")).to eq 1
      expect(hash.dig(:subhash_symbol, 0, :key)).to eq 1
    end
    # rubocop:enable RSpec/MultipleExpectations
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
