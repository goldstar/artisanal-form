module Artisanal::Form
  class Attribute < Artisanal::Model::Attribute
    def type_builder(type=self.type)
      if type.is_a?(Class) && type.respond_to?(:artisanal_form)
        return ->(value, parent) {
          value.is_a?(type) ? value : type.new(value, parent.context)
        }
      end
      super(type)
    end
  end
end
