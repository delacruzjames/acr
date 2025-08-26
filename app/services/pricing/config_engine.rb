# frozen_string_literal: true
module Pricing
  class ConfigEngine < PricingEngine
    def initialize
      super(RulesLoader.load_from_env_or_yaml) # => array of rule objects
    end
  end
end
