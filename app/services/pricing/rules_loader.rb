# frozen_string_literal: true
require "json"
require "bigdecimal"
require "bigdecimal/util"

module Pricing
  class RulesLoader
    class << self
      # Public entry: returns a normalized Hash keyed by product code
      # Example:
      # {
      #   "GR1"=>{ bogof: true },
      #   "SR1"=>{ bulk_price_drop: { min_qty: 3, new_unit_price: BigDecimal("4.5") } },
      #   "CF1"=>{ fraction_drop: { min_qty: 3, numerator: 2.to_d, denominator: 3.to_d, rounding: "line_total" } }
      # }
      def load_from_env_or_yaml
        raw =
          if ENV["PRICING_RULES_JSON"].present?
            JSON.parse(ENV["PRICING_RULES_JSON"])
          else
            Rails.application.config_for(:pricing_rules)
          end

        normalize(raw || {})
      end

      private

      def normalize(raw)
        raw.each_with_object({}) do |(code, cfg), acc|
          next unless cfg.is_a?(Hash)
          h = {}

          if cfg["bogof"]
            h[:bogof] = true
          end

          if (bp = cfg["bulk_price_drop"]).is_a?(Hash)
            h[:bulk_price_drop] = {
              min_qty: bp["min_qty"].to_i,
              new_unit_price: BigDecimal(bp["new_unit_price"].to_s)
            }
          end

          if (fd = cfg["fraction_drop"]).is_a?(Hash)
            h[:fraction_drop] = {
              min_qty: fd["min_qty"].to_i,
              numerator: BigDecimal(fd["numerator"].to_s),
              denominator: BigDecimal(fd["denominator"].to_s),
              rounding: (fd["rounding"] || "line_total").to_s
            }
          end

          acc[code] = h unless h.empty?
        end
      end
    end
  end
end
