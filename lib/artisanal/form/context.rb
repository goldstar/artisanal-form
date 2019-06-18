require 'dry-container'

module Artisanal::Form
  class Context
    extend Forwardable

    delegate [:register, :[]] => :container

    def apply(scope, context_registry)
      context_registry.each do |name, config|
        scoped_item = -> { scope.instance_exec(&config[:item]) }
        register(name, config[:options], &scoped_item)
      end
    end

    def container
      @container ||= Dry::Container.new
    end
  end
end
