# frozen_string_literal: true
require "rails_helper"
require "bigdecimal/util"

RSpec.describe Pricing::ConfigEngine do
  after { ENV.delete("PRICING_RULES_JSON") }

  let(:rules_hash) do
    {
      "GR1" => { "bogof" => true },
      "SR1" => { "bulk_price_drop" => { "min_qty" => 3, "new_unit_price" => 4.50 } },
      "CF1" => { "fraction_drop" => { "min_qty" => 3, "numerator" => 2, "denominator" => 3, "rounding" => "line_total" } }
    }
  end

  def snap(*codes)
    prices = { "GR1" => 3.11.to_d, "SR1" => 5.00.to_d, "CF1" => 11.23.to_d }
    h = Hash.new { |x, k| x[k] = { qty: 0, unit_price: 0.to_d } }
    codes.each do |code|
      h[code][:qty]        += 1
      h[code][:unit_price]  = prices.fetch(code)
    end
    h
  end

  before do
    # drive ConfigEngine through the loader using ENV config
    ENV["PRICING_RULES_JSON"] = JSON.generate(rules_hash)
  end

  it "matches the provided basket totals" do
    e = described_class.new
    expect(e.price(snap("GR1","SR1","GR1","CF1"))[:total].to_f).to eq(19.34)
    expect(e.price(snap("GR1","GR1"))[:total].to_f).to               eq(3.11)
    expect(e.price(snap("SR1","SR1","GR1","SR1"))[:total].to_f).to   eq(16.61)
    expect(e.price(snap("GR1","CF1","SR1","CF1","CF1"))[:total].to_f).to eq(30.57)
  end

  it "is order-independent" do
    e = described_class.new
    a = e.price(snap("GR1","CF1","SR1","CF1","CF1"))[:total]
    b = e.price(snap("CF1","GR1","CF1","SR1","CF1"))[:total]
    expect(a).to eq(b)
  end
end
