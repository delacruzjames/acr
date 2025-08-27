# frozen_string_literal: true
require "json"
require "bigdecimal"

module Pricing
  class RulesLoader
    ORDER = %w[bogof bulk_price_drop fraction_drop].freeze

    class << self
      # Returns an Array of instantiated rule objects (Bogof/Bulk/Fraction)
      def load_from_env_or_yaml
        raw =
          if ENV["PRICING_RULES_JSON"].present?
            JSON.parse(ENV["PRICING_RULES_JSON"])
          else
            Rails.application.config_for(:pricing_rules)
          end

        build_rules(raw || {})
      end

      def normalized_config
        raw =
          if ENV["PRICING_RULES_JSON"].present?
            JSON.parse(ENV["PRICING_RULES_JSON"])
          else
            Rails.application.config_for(:pricing_rules)
          end
        normalize(raw || {})
      end

      private

      # Build Array of rule objects
      def build_rules(raw)
        rules = []
        raw.each do |code, cfg|
          next unless cfg.is_a?(Hash)

          # Rails config_for may return HashWithIndifferentAccess; to_h is fine
          cfg = cfg.to_h

          ORDER.each do |kind|
            params = cfg[kind]
            next unless params || kind == "bogof"

            case kind
            when "bogof"
              rules << Rules::BogofRule.new(code: code) if params
            when "bulk_price_drop"
              rules << Rules::BulkPriceDropRule.new(
                code: code,
                min_qty:  integer!(params, "min_qty", code, kind),
                new_unit_price: decimal!(params, "new_unit_price", code, kind)
              )
            when "fraction_drop"
              rules << Rules::FractionDropRule.new(
                code: code,
                min_qty:   integer!(params, "min_qty", code, kind),
                numerator: decimal!(params, "numerator", code, kind),
                denominator: decimal!(params, "denominator", code, kind),
                rounding: (params["rounding"] || "line_total")
              )
            end
          end
        end
        
        # --- _global section ---
        if (g = raw["_global"]).is_a?(Hash)
          if (gift = g["buy_any_get_gift"]).is_a?(Hash)
            rules << Rules::BuyAnyGetGiftRule.new(
              gift_code: gift.fetch("gift_code"),
              gift_qty: integer!(gift, "gift_qty", "_global", "buy_any_get_gift"),
              gift_has_bogof: gift.fetch("gift_has_bogof", true)
            )
          end
        end
        rules
      end

      # Normalizes into a hash of typed values (handy for debugging)
      def normalize(raw)
        return {} unless raw.is_a?(Hash)
        raw.each_with_object({}) do |(code, cfg), acc|
          next unless cfg.is_a?(Hash)
          h = {}

          h[:bogof] = true if cfg["bogof"]

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

      # ---- helpers for nice error messages / type coercion ----
      def integer!(h, key, code, kind)
        v = h[key]
        raise ArgumentError, "Missing #{key} for #{code}.#{kind}" if v.nil?
        Integer(v)
      end

      def decimal!(h, key, code, kind)
        v = h[key]
        raise ArgumentError, "Missing #{key} for #{code}.#{kind}" if v.nil?
        BigDecimal(v.to_s)
      end
    end
  end
end
