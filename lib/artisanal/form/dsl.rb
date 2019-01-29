require 'active_support/core_ext/hash/deep_merge'

module Artisanal::Form
  require_relative 'coordinator'
  require_relative 'initializer'
  require_relative 'validators'

  module DSL
    def self.extended(base)
      base.prepend Initializer
      base.include InstanceMethods
    end

    def coordinator
      @coordinator ||= Coordinator.new(self)
    end

    def segments
      coordinator.segments
    end

    def segment(*args)
      coordinator.segment(*args)
    end

    def validates_associated(name, options={})
      validates_with Validators::AssociatedValidator,
        { attributes: [name], errors: :deep }.merge(options)
    end

    module InstanceMethods
      attr_reader :input

      def assign_attributes(attributes)
        @segments = nil
        super(input.deep_merge!(attributes.to_h))
      end

      def segments
        @segments ||= self.class.segments.each.with_object({}) { |(name, segment), memo|
          memo[name] = segment.constructor.new(input)
        }
      end

      def errors
        @errors ||= Artisanal::Form::Errors.new(super)
      end

      def to_h(*args)
        segment_hash = segments.values.map { |segment| segment.to_h(*args) }
        ([super(*args)] + segment_hash).reduce(&:deep_merge)
      end

      def empty?
        to_h.empty?
      end

      def method_missing(name, *args, &block)
        segments[name] || super
      end

      def respond_to_missing?(name, *args)
        segments.keys.include?(name) || super
      end

      def status
        segments.each.with_object({}) do |(name, segment), status|
          if segment.empty?
            status[name] = :skipped
          elsif segment.invalid?
            status[name] = :invalid
          elsif segment.valid?
            status[name] = :valid
          end
        end
      end
    end
  end
end
