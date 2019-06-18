module Artisanal::Form
  require_relative 'attribute'
  require_relative 'coordinator'

  class Form
    extend Forwardable

    attr_reader :klass

    delegate [:segment, :segments] => :coordinator

    def initialize(klass)
      @klass = klass
    end

    def attribute(name, type=nil, **options)
      klass.include Attribute.new(name, type, **options)
    end

    def context_registry
      @context_registry ||= {}
    end

    def coordinator
      @coordinator ||= Coordinator.new(klass)
    end

    def register_context(name, method_name=nil, options={}, &block)
      item = block || -> { self.send(method_name) }
      options = { call: true, memoize: true }.merge(options)

      context_registry[name] = { item: item, options: options }
    end
  end
end
