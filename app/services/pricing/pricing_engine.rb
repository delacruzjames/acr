# frozen_string_literal: true
require "bigdecimal"
require "bigdecimal/util"

module Pricing
  class PricingEngine
    def initialize(rules)
      @rules = Array(rules)
    end

    def price(snapshot)
      lines = deep_dup(snapshot) # no Marshal, works with default proc hashes

      @rules.each { |rule| rule.apply!(lines) }

      total = lines.sum do |_code, h|
        qty  = h[:qty].to_i
        unit = (h[:effective_unit_price] || h[:unit_price]).to_d
        h[:line_total_override] || (unit * qty)
      end

      { lines: lines, total: total.round(2) }
    end

    private

    # Proc-safe deep dup (Hash/Array/BigDecimal), no Marshal
    def deep_dup(obj)
      case obj
      when Hash
        dup_hash = {}
        obj.each { |k, v| dup_hash[k] = deep_dup(v) }
        dup_hash
      when Array
        obj.map { |e| deep_dup(e) }
      when BigDecimal
        obj
      else
        begin
          obj.dup
        rescue TypeError
          obj
        end
      end
    end
  end
end
