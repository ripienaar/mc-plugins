module MCollective
  module Validator
    class Exim_msgidValidator
      def initialize(key, validator)
        @validator = validator
        @key = key
      end

      def validate
        raise DDLValidationError, "#{@key} should be a String" unless @validator.is_a?(String)

        raise(DDLValidationError, "%s should be a valid Exim Message ID" % @key) unless @validator.match(/(?:[+-]\d{4} )?(?:\[\d+\] )?(\w{6}\-\w{6}\-\w{2})/)
      end
    end
  end
end
