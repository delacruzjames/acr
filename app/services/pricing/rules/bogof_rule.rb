# frozen_string_literal: true
require "bigdecimal/util"

module Pricing
  module Rules
    # Buy-One-Get-One-Free: pay for ceil(qty/2) units.
    class BogofRule
      def initialize(code:) = (@code = code)

      def apply!(lines)
        it = lines[@code]
        return unless it

        qty  = it[:qty].to_i
        return if qty <= 0

        unit = it[:unit_price].to_d
        chargeable = (qty / 2.0).ceil

        line_total = (unit * chargeable).round(2)
        it[:line_total_override]  = line_total
        it[:effective_unit_price] = (line_total / qty).round(2) # display-only
        it
      end
    end
  end
end
