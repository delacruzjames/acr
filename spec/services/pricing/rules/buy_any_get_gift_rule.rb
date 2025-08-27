# app/lib/pricing/rules/buy_any_get_gift_rule.rb
# frozen_string_literal: true
require "bigdecimal"
require "bigdecimal/util"

module Pricing
  module Rules
    # Adds a free gift (e.g., 1× GR1) when the cart has any item.
    # Safe with GR1 BOGOF, bulk, etc. Runs best *after* other rules.
    class BuyAnyGetGiftRule
      def initialize(gift_code:, gift_qty:, gift_has_bogof: true)
        @gift_code      = gift_code
        @gift_qty       = gift_qty.to_i
        @gift_has_bogof = !!gift_has_bogof
      end

      def apply!(lines)
        # "Any item" present? (exclude nil keys; qty must be > 0)
        has_any = lines.any? { |code, h| code && h.is_a?(Hash) && h[:qty].to_i > 0 }
        return unless has_any

        gift = (lines[@gift_code] ||= { qty: 0, unit_price: BigDecimal("0") })
        gift[:qty] += @gift_qty

        gqty = gift[:qty].to_i
        unit = gift[:unit_price].to_d  # may be 0 if GR1 wasn’t scanned; that’s ok

        # If GR1 has BOGOF, base chargeables are ceil(q/2), then subtract the free gifts.
        base_chargeable = @gift_has_bogof ? ((gqty) / 2.0).ceil : gqty
        chargeable      = [base_chargeable - @gift_qty, 0].max

        line_total = (unit * chargeable).round(2, BigDecimal::ROUND_HALF_UP)
        gift[:line_total_override]  = line_total
        gift[:effective_unit_price] = gqty.zero? ? 0 : (line_total / gqty).round(2, BigDecimal::ROUND_HALF_UP)
        gift
      end
    end
  end
end
