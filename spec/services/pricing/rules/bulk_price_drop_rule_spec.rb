# frozen_string_literal: true
require "rails_helper"
require "bigdecimal/util"

RSpec.describe Pricing::Rules::BulkPriceDropRule do
  it "does nothing when qty < min_qty" do
    lines = { "SR1" => { qty: 2, unit_price: 5.00.to_d } }
    described_class.new(code: "SR1", min_qty: 3, new_unit_price: 4.50).apply!(lines)
    expect(total_for(lines)).to eq(10.00)
    expect(lines["SR1"][:effective_unit_price]).to be_nil
  end

  it "drops all units to new price when qty >= min_qty" do
    lines = { "SR1" => { qty: 3, unit_price: 5.00.to_d } }
    described_class.new(code: "SR1", min_qty: 3, new_unit_price: 4.50).apply!(lines)
    expect(total_for(lines)).to eq(13.50)
    expect(lines["SR1"][:effective_unit_price].to_s("F")).to eq("4.5")
  end

  it "clears any existing line_total_override (e.g., from BOGOF)" do
    lines = { "SR1" => { qty: 4, unit_price: 5.00.to_d, line_total_override: 10.00.to_d } }
    described_class.new(code: "SR1", min_qty: 3, new_unit_price: 4.50).apply!(lines)
    expect(lines["SR1"][:line_total_override]).to be_nil
    expect(total_for(lines)).to eq(18.00) # 4 * 4.50
  end
end
