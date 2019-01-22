require 'artisanal-model'

module Artisanal::Form
  require_relative 'dsl'

  class Builder < Module
    attr_reader :options

    def initialize(options={})
      @options = defaults.merge(options)
    end

    def included(base)
      base.include Artisanal::Model(options)
      base.include ActiveModel::Validations
      base.extend  Artisanal::Form::DSL
    end

    protected

    def defaults
      {
        symbolize: true,
        writable: true
      }
    end
  end
end
