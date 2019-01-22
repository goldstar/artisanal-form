module Artisanal::Form
  require_relative 'segment'

  class Coordinator
    attr_reader :klass, :segments

    def initialize(klass)
      @klass = klass
      @segments = {}
    end

    def segment(name, *args)
      Segment.new(name, *args).tap do |segment|
        segments[name] = segment
        klass.include segment
      end
    end
  end
end
