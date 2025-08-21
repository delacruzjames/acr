# frozen_string_literal: true
require "rails_helper"

RSpec.describe Pricing::RulesLoader do
  after { ENV.delete("PRICING_RULES_JSON") }

  let(:rules_hash) do
    {
      "GR1" => { "bogof" => true },
      "SR1" => { "bulk_price_drop" => { "min_qty" => 3, "new_unit_price" => 4.50 } },
      "CF1" => { "fraction_drop" => { "min_qty" => 3, "numerator" => 2, "denominator" => 3, "rounding" => "line_total" } }
    }
  end

  it "loads and normalizes from ENV JSON when present" do
    ENV["PRICING_RULES_JSON"] = JSON.generate(rules_hash)

    cfg = described_class.load_from_env_or_yaml
    expect(cfg.keys).to match_array(%w[GR1 SR1 CF1])

    expect(cfg["GR1"]).to eq({ bogof: true })

    expect(cfg["SR1"][:bulk_price_drop][:min_qty]).to eq(3)
    expect(cfg["SR1"][:bulk_price_drop][:new_unit_price]).to be_a(BigDecimal)
    expect(cfg["SR1"][:bulk_price_drop][:new_unit_price].to_s("F")).to eq("4.5")

    expect(cfg["CF1"][:fraction_drop][:min_qty]).to eq(3)
    expect(cfg["CF1"][:fraction_drop][:numerator]).to be_a(BigDecimal)
    expect(cfg["CF1"][:fraction_drop][:denominator]).to be_a(BigDecimal)
    expect(cfg["CF1"][:fraction_drop][:rounding]).to eq("line_total")
  end

  it "falls back to Rails config_for(:pricing_rules) when ENV is not set" do
    allow(Rails.application).to receive(:config_for).with(:pricing_rules).and_return(rules_hash)

    cfg = described_class.load_from_env_or_yaml
    expect(cfg.keys).to match_array(%w[GR1 SR1 CF1])
  end

  it "returns {} when config is empty" do
    allow(Rails.application).to receive(:config_for).with(:pricing_rules).and_return({})

    cfg = described_class.load_from_env_or_yaml
    expect(cfg).to eq({})
  end
end
