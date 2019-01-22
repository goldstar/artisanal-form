module Artisanal::Form
  require_relative 'validators'

  class Segment < Module
    include ActiveModel::Validations::HelperMethods

    attr_reader :name, :constructor, :options

    def initialize(name, constructor, options={})
      @name, @constructor = name, constructor
      @options = { validate: true, errors: :merge }.merge(options)
    end

    def included(base)
      base.validates_associated(name, options) if options[:validate]
    end
  end
end
