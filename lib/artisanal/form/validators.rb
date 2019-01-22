module Artisanal::Form
  module Validators
    class AssociatedValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        return if value.nil? && options[:allow_nil]
        return if value.blank? && options[:allow_blank]

        if value.nil? || value.blank?
          handle_nil(record, attribute)
        elsif options[:errors] == :merge
          validate_each_merge(record, attribute, value)
        elsif options[:errors] == :deep
          validate_each_deep(record, attribute, value)
        elsif options[:errors] == :shallow
          validate_each_shallow(record, attribute, value)
        end
      end

      private

      def validate_each_shallow(record, attribute, value)
        return if Array(value).all?(&:valid?)
        record.errors.add(attribute, options[:message] || "is invalid")
      end

      def validate_each_deep(record, attribute, value)
        if value.is_a?(Array)
          errors = value.each.with_object({}).with_index do |(v, memo), i|
            memo[i] = v.errors.to_h if v.invalid?
          end
          record.errors.add(attribute, errors) if errors.present?
        else
          record.errors.add(attribute, value.errors.to_h) if value.invalid?
        end
      end

      def validate_each_merge(record, attribute, value)
        if value.is_a?(Array)
          errors = value.each.with_object({}).with_index do |(v, memo), i|
            memo[i] = v.errors.to_h if v.invalid?
          end
          record.errors.add(attribute, errors) if errors.present?
        else
          record.errors.merge(value.errors) if value.invalid?
        end
      end

      def handle_nil(record, attribute)
        message = options[:message] || "can't be blank"
        record.errors.add(attribute, message)
      end
    end
  end
end
