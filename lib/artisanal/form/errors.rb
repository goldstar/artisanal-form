module Artisanal::Form
  class Errors < SimpleDelegator
    require_relative 'errors/formatter'

    def add(*args)
      super(*args) unless added?(*args)
    end

    def merge(other_errors)
      other_errors.each do |attribute, message|
        add(attribute, message)
      end
    end

    def formatted(formatter: Formatter.instance)
      formatter.call(to_h)
    end
  end
end
