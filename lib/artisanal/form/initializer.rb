require 'active_support/core_ext/hash/indifferent_access'

module Artisanal::Form
  require_relative 'context'

  module Initializer
    def initialize(input={}, parent=nil)
      # Setup context on instance
      @context = parent&.context || Context.new
      @context.apply(self, artisanal_form.context_registry)

      # Persist input for segments
      @input = input.to_h.with_indifferent_access

      super(input, parent)
    end
  end
end
