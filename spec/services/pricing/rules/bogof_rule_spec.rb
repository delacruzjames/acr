# frozen_string_literal: true
require "rails_helper"
require "bigdecimal/util"

RSpec.describe Pricing::Rules::BogofRule do
  it "charges ceil(q/2) * unit for q=2" do
    lines = { "GR1" => { qty: 2, unit_price: 3.11.to_d } }
    described_class.new(code: "GR1").apply!(lines)
    expect(total_for(lines)).to eq(3.11)
    expect(lines["GR1"][:line_total_override].to_f).to eq(3.11)
  end

  it "charges ceil(q/2) * unit for q=3" do
    lines = { "GR1" => { qty: 3, unit_price: 3.11.to_d } }
    described_class.new(code: "GR1").apply!(lines)
    expect(total_for(lines)).to eq(6.22) # 2 * 3.11
  end

  it "does nothing when qty is 0" do
    lines = { "GR1" => { qty: 0, unit_price: 3.11.to_d } }
    described_class.new(code: "GR1").apply!(lines)
    expect(lines["GR1"][:line_total_override]).to be_nil
    expect(lines["GR1"][:effective_unit_price]).to be_nil
  end
end
