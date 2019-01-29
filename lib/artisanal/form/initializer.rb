require 'active_support/core_ext/hash/indifferent_access'

module Artisanal::Form
  module Initializer
    def initialize(input={})
      super(input)
      @input = input.to_h.with_indifferent_access
    end
  end
end
