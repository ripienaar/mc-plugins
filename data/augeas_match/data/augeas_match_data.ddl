metadata    :name        => "Augeas Match",
            :description => "Allows agents and discovery to do Augeas match lookups",
            :author      => "R.I.Pienaar <rip@devco.net>",
            :license     => "Apache License, Version 2.0",
            :version     => "1.0",
            :url         => "http://marionette-collective.org/",
            :timeout     => 2

dataquery :description => "Match data using Augeas" do
    input :query,
          :prompt => "Matcher",
          :description => "Valid Augeas match expression",
          :type => :string,
          :validation => /.+/,
          :maxlength => 50

    output :size,
           :description => "The amont of records matched",
           :display_as => "Matched"
end
