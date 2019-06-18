require 'active_model'
require 'forwardable'

module Artisanal
  require_relative "form/builder"
  require_relative "form/errors"
  require_relative "form/version"

  def self.Form(**opts)
    Form::Builder.new(**opts)
  end

  module Form
    def self.included(base)
      base.include Artisanal::Form()
    end
  end
end
