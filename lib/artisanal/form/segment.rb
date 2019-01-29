module Artisanal::Form
  require_relative 'validators'

  class Segment < Module
    include ActiveModel::Validations::HelperMethods

    attr_reader :name, :constructor, :options

    def initialize(name, constructor, options={})
      @name, @constructor = name, constructor
      @options = defaults.merge(options)
    end

    def included(base)
      base.validates_associated(name, options) if options[:validate]
    end

    protected

    def defaults
      {
        validate: true,
        errors: :merge,
        unless: :empty?,
        allow_blank: true
      }
    end
  end
end
