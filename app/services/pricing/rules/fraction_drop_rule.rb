# frozen_string_literal: true
require "bigdecimal/util"

module Pricing
  module Rules
    class FractionDropRule
      def initialize(code:, min_qty:, numerator:, denominator:, rounding: "line_total")
        @code = code
        @min_qty = min_qty.to_i
        @num = BigDecimal(numerator.to_s)
        @den = BigDecimal(denominator.to_s)
        @rounding = rounding.to_s
      end

      def apply!(lines)
        it = lines[@code]
        return unless it

        qty  = it[:qty].to_i
        return if qty < @min_qty

        unit = it[:unit_price].to_d
        factor = @num / @den

        if @rounding == "unit"
          it[:effective_unit_price] = (unit * factor).round(2)
          it.delete(:line_total_override) # per-unit pricing replaces any prior override
        else
          line_total = (unit * qty * factor).round(2)
          it[:line_total_override]  = line_total
          it[:effective_unit_price] = (line_total / qty).round(2)
        end

        it
      end
    end
  end
end
