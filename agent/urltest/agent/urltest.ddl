metadata    :name        => "URL Tester",
            :description => "Agent that connects to a URL and returns some statistics",
            :author      => "R.I.Pienaar <rip@devco.net>",
            :license     => "ASL 2.0",
            :version     => "2.0",
            :url         => "https://github.com/ripienaar/mc-plugins",
            :timeout     => 60

requires :mcollective => "2.2.1"

action "perftest", :description => "Perform URL test" do
    display :always

    input :url,
          :prompt      => "URL",
          :description => "The URL to test, only http is supported",
          :type        => :string,
          :validation  => '^http:\/\/',
          :optional    => false,
          :maxlength   => 120

    output :lookuptime,
          :description => "Time to perform DNS lookup",
          :display_as  => "DNS lookup time"

    output :connectime,
          :description => "Time to open TCP connection",
          :display_as  => "TCP connect time"

    output :prexfertime,
          :description => "Time between socket open and first reply",
          :display_as  => "Pre transfer time"

    output :startxfer,
          :description => "Time between between sending the request and receiving reply",
          :display_as  => "Request wait time"

    output :bytesfetched,
          :description => "Size of the reply in bytes",
          :display_as  => "Bytes"

    output :totaltime,
          :description => "Total test time",
          :display_as  => "Total time"

    output :testerlocation,
          :description => "Location where the server is based",
          :display_as  => "Tested from"

    summarize do
        aggregate average(:lookuptime, :format => "Average DNS lookup time: %0.6f")
        aggregate average(:connectime, :format => "Average TCP connect time: %0.6f")
        aggregate average(:prexfertime, :format => "Average time to first byte: %0.6f")
        aggregate average(:startxfer, :format => "Average HTTP response time: %0.6f")
        aggregate average(:totaltime, :format => "Average total test time: %0.6f")
    end
end
