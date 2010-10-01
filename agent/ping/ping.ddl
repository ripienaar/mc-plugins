metadata    :name        => "Ping",
            :description => "Agent to ping from a location",
            :author      => "Dean Smith <dean@zelotus.com>",
            :license     => "GPL2",
            :version     => "1.0",
            :url         => "http://github.com/deasmi/mcollective-plugins",
            :timeout     => 60

action "ping", :description => "Returns rrt of ping to host" do
    display :always

    input :fqdn,
        :prompt => "FQDN",
        :description => "The fully qualified domain name to ping",
        :type => :string,
        :validation => '^.+$',	
        :optional => false,
        :maxlength => 80
  
    output :rtt,
        :description => "The round trip time in ms",
        :display_as=>"RTT"

    output :fqdn,
        :description=>"The hosts fqdn",
        :display_as=>"FQDN"

    output :time,
        :description => "The time the ping was received",
        :display_as => "Time"
end
