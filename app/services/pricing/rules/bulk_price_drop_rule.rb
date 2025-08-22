# frozen_string_literal: true
require "bigdecimal"

module Pricing
  module Rules
    class BulkPriceDropRule
      def initialize(code:, min_qty:, new_unit_price:)
        @code = code
        @min_qty = min_qty.to_i
        @new_price = BigDecimal(new_unit_price.to_s)
      end

      def apply!(lines)
        it = lines[@code]
        return unless it

        qty = it[:qty].to_i
        return if qty < @min_qty

        it[:effective_unit_price] = @new_price
        it.delete(:line_total_override) # bulk overrides any prior BOGOF override
        it
      end
    end
  end
end
