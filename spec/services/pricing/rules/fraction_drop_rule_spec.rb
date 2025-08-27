# frozen_string_literal: true
require "rails_helper"
require "bigdecimal/util"

RSpec.describe Pricing::Rules::FractionDropRule do
  it "applies 2/3 line-total rounding when qty >= min (default rounding)" do
    lines = { "CF1" => { qty: 3, unit_price: 11.23.to_d } }
    described_class.new(code: "CF1", min_qty: 3, numerator: 2, denominator: 3).apply!(lines)
    expect(total_for(lines)).to eq(22.46) # (3*11.23)*2/3 rounded
    expect(lines["CF1"][:line_total_override]).to be_present
  end

  it "does nothing when qty < min" do
    lines = { "CF1" => { qty: 2, unit_price: 11.23.to_d } }
    described_class.new(code: "CF1", min_qty: 3, numerator: 2, denominator: 3).apply!(lines)
    expect(total_for(lines)).to eq(22.46)
    expect(lines["CF1"][:line_total_override]).to be_nil
  end

  it "supports rounding per-unit (may drift by a cent)" do
    lines = { "CF1" => { qty: 3, unit_price: 11.23.to_d } }
    described_class.new(code: "CF1", min_qty: 3, numerator: 2, denominator: 3, rounding: "unit").apply!(lines)
    expect(total_for(lines)).to eq(22.47) # 7.49 * 3
    expect(lines["CF1"][:line_total_override]).to be_nil
  end
end
