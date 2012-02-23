metadata    :name        => "rndc",
            :description => "SimpleRPC RNDC Agent",
            :author      => "R.I.Pienaar <rip@devco.net>",
            :license     => "ASL2.0",
            :version     => "0.2",
            :url         => "http://www.devco.net/",
            :timeout     => 5

["reload", "freeze", "thaw"].each do |act|
    action act, :description => "#{act.capitalize} a zone or all zones" do
        input :zone,
            :prompt      => "Zone",
            :description => "Zone to act on",
            :type        => :string,
            :validation  => '^.+$',
            :optional    => true,
            :maxlength   => 100

        output :out,
               :description => "STDOUT output",
               :display_as => "Output"

        output :err,
               :description => "STDERR output",
               :display_as => "Error"
    end
end

["refresh", "retransfer", "notify", "sign"].each do |act|
    action act, :description => "#{act.capitalize} a zone" do
        input :zone,
            :prompt      => "Zone",
            :description => "Zone to act on",
            :type        => :string,
            :validation  => '^.+$',
            :optional    => false,
            :maxlength   => 100

        output :out,
               :description => "STDOUT output",
               :display_as => "Output"

        output :err,
               :description => "STDERR output",
               :display_as => "Error"
    end
end

action "reconfig", :description => "Reloads the server configuration" do
    output :out,
           :description => "STDOUT output",
           :display_as => "Output"

    output :err,
           :description => "STDERR output",
           :display_as => "Error"
end

action "querylog", :description => "Toggles the server wide querylog" do
    output :out,
           :description => "STDOUT output",
           :display_as => "Output"

    output :err,
           :description => "STDERR output",
           :display_as => "Error"
end

action "flush", :description => "Flushes all of the server's caches." do
    output :out,
           :description => "STDOUT output",
           :display_as => "Output"

    output :err,
           :description => "STDERR output",
           :display_as => "Error"
end

action "status", :description => "Gather server status information" do
    display :always

    output :debug_level,
           :description => "Active debug level",
           :display_as => "Debug Level"

    output :version,
           :description => "Server Version",
           :display_as => "Version"

    output :soa_queries_in_progress,
           :description => "Active SOA queries",
           :display_as => "SOA Queries in Progress"

    output :worker_threads,
           :description => "Number of Worker Threads",
           :display_as => "Worker Threads"

    output :recursive_clients,
           :description => "Recursive Clients",
           :display_as => "Recursive Clients"

    output :xfers_running,
           :description => "Active transfers",
           :display_as => "Xfers Running"

    output :number_of_zones,
           :description => "Number of zones",
           :display_as => "Zones"

    output :xfers_deferred,
           :description => "Number of Xfers deferred",
           :display_as => "Xfers Deferred"

    output :tcp_clients,
           :description => "TCP Clients",
           :display_as => "TCP Clients"

    output :cpus_found,
           :description => "Number of CPUs Found",
           :display_as => "CPUs"
end
