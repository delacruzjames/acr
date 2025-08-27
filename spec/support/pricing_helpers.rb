# spec/support/pricing_helpers.rb
module PricingHelpers
  def total_for(lines)
    lines.sum do |_code, h|
      qty  = h[:qty].to_i
      unit = (h[:effective_unit_price] || h[:unit_price]).to_d
      (h[:line_total_override] || (unit * qty))
    end.round(2).to_f
  end
end

RSpec.configure do |config|
  config.include PricingHelpers
end
