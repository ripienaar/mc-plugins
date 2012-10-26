module MCollective
  module Validator
    class Exim_msgidValidator
      def self.validate(msgid)
        Validator.typecheck(msgid, :string)

        raise "Not a valid Exim Message ID" unless msgid.match(/(?:[+-]\d{4} )?(?:\[\d+\] )?(\w{6}\-\w{6}\-\w{2})/)
      end
    end
  end
end
