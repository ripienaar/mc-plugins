module MCollective
  module Data
    class Augeas_match_data<Base
      require 'augeas'

      query do |what|
        aug = Augeas.open

        result[:size] = aug.match(what).size
      end
    end
  end
end

