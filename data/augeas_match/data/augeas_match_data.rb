module MCollective
  module Data
    class Augeas_match_data<Base
      activate_when { require 'augeas' }

      query do |what|
        aug = Augeas.open

        result[:size] = aug.match(what).size
      end
    end
  end
end

