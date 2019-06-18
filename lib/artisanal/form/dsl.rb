require 'active_support/core_ext/hash/deep_merge'

module Artisanal::Form
  require_relative 'initializer'
  require_relative 'form'
  require_relative 'prepopulator'
  require_relative 'validators'

  module DSL
    extend Forwardable

    delegate [:register_context, :segment, :segments] => :artisanal_form

    def self.extended(base)
      base.prepend Initializer
      base.include InstanceMethods
    end

    def artisanal_form
      @artisanal_form ||= Form.new(self)
    end

    def prepopulator
      const_get('Prepopulator')
    rescue NameError
      NullPrepopulator
    end

    def validates_associated(name, options={})
      validates_with Validators::AssociatedValidator,
        { attributes: [name], errors: :deep }.merge(options)
    end

    module InstanceMethods
      attr_reader :context, :input

      def artisanal_form
        self.class.artisanal_form
      end

      def assign_attributes(attributes)
        @segments = nil
        super(input.deep_merge!(attributes.to_h))
      end

      def empty?
        to_h.empty?
      end

      def errors
        @errors ||= Artisanal::Form::Errors.new(super)
      end

      def method_missing(name, *args, &block)
        segments[name] || super
      end

      def prepopulate!(*args)
        self.class.prepopulator.new(self, *args).tap do |prepopulator|
          prepopulator.prepopulate!
        end
      end

      def respond_to_missing?(name, *args)
        segments.keys.include?(name) || super
      end

      def segments
        @segments ||= self.class.segments.each.with_object({}) { |(name, segment), memo|
          memo[name] = segment.constructor.new(input)
        }
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

      def to_h(*args)
        segment_hash = segments.values.map { |segment| segment.to_h(*args) }
        ([super(*args)] + segment_hash).reduce(&:deep_merge)
      end
    end
  end
end
