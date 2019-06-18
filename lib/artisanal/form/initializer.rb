require 'active_support/core_ext/hash/indifferent_access'

module Artisanal::Form
  require_relative 'context'

  module Initializer
    def initialize(input={}, context=Context.new)
      context.apply(self, artisanal_form.context_registry)

      @context = context
      @input = input.to_h.with_indifferent_access

      super(input)
    end
  end
end
