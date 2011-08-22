metadata    :name        => "libvirt",
            :description => "SimpleRPC Libvirt Agent",
            :author      => "R.I.Pienaar <rip@devco.net>",
            :license     => "ASL2.0",
            :version     => "0.1",
            :url         => "http://devco.net/",
            :timeout     => 10

action "hvinfo", :description => "Hypervisor Information" do
    display :always

    output :model,
           :description => "Hypervisor Model",
           :display_as => "Model"

    output :memory,
           :description => "Hypervisor Total Memory",
           :display_as => "Memory"

    output :cpus,
           :description => "Number of CPUs",
           :display_as => "CPUs"

    output :mhz,
           :description => "CPU Clock Frequency",
           :display_as => "MHz"

    output :nodes,
           :description => "Number of NUMA Nodes",
           :display_as => "Numa Nodes"

    output :sockets,
           :description => "CPU Sockets",
           :display_as => "Sockets"

    output :cores,
           :description => "CPU Cores",
           :display_as => "Cores"

    output :threads,
           :description => "CPU Threads",
           :display_as => "Threads"

    output :type,
           :description => "Hypervisor Type",
           :display_as => "Type"

    output :version,
           :description => "Hypervisor Version",
           :display_as => "Version"

    output :uri,
           :description => "Hypervisor URI",
           :display_as => "URI"

    output :node_free_memory,
           :description => "Total Free Memory",
           :display_as => "Free Memory"

    output :active_domains,
           :description => "Active Domains",
           :display_as => "Active Domains"

    output :inactive_domains,
           :description => "Inactive Domains",
           :display_as => "Inactive Domains"

    output :max_vcpus,
           :description => "Maximum virtual CPUs",
           :display_as => "Max VCPUs"
end

action "domaininfo", :description => "Domain Information" do
    display :ok

    input :domain,
        :prompt      => "Domain Name",
        :description => "Name of a defined domain",
        :type        => :string,
        :validation  => '^.+$',
        :optional    => false,
        :maxlength   => 50

    output :autostart,
           :description => "Will the domain auto start",
           :display_as => "Autostart"

    output :vcpus,
           :description => "Number of Virtual CPUs",
           :display_as => "VCPUs"

    output :memory,
           :description => "Current Memory",
           :display_as => "Memory"

    output :max_memory,
           :description => "Maximum Memory",
           :display_as => "Max Memory"

    output :cputime,
           :description => "CPU Time",
           :display_as => "CPU Time"

    output :state,
           :description => "Domain State",
           :display_as => "State Code"

    output :state_description,
           :description => "Domain State",
           :display_as => "State"

    output :uuid,
           :description => "Domain UUID",
           :display_as => "UUID"
end

action "domainxml", :description => "Retrieve the full libvirt XML description for a domain" do
    display :ok

    input :domain,
        :prompt      => "Domain Name",
        :description => "Name of a defined domain",
        :type        => :string,
        :validation  => '^.+$',
        :optional    => false,
        :maxlength   => 50

    output :xml,
           :description => "Domain XML",
           :display_as => "XML"
end

action "definedomain", :description => "Defines a domain from a XML file describing it" do
    display :always

    input :domain,
        :prompt      => "Domain Name",
        :description => "Name of a defined domain",
        :type        => :string,
        :validation  => '^.+$',
        :optional    => false,
        :maxlength   => 50

    input :permanent,
        :prompt      => "Permanent",
        :description => "Should the domain persist reboots",
        :type        => :boolean,
        :optional    => true

    output :state,
           :description => "Domain State",
           :display_as => "State Code"

    output :state_description,
           :description => "Domain State",
           :display_as => "State"
end

action "undefinedomain", :description => "Undefines a domain" do
    input :domain,
        :prompt      => "Domain Name",
        :description => "Name of a defined domain",
        :type        => :string,
        :validation  => '^.+$',
        :optional    => false,
        :maxlength   => 50

    input :destroy,
        :prompt      => "Destroy",
        :description => "Should the domain be destroyed before undefining",
        :type        => :boolean,
        :optional    => true

    output :status,
           :description => "Status",
           :display_as => "Status"
end

[:destroy, :shutdown, :suspend, :resume, :create, :start].each do |act|
    action act.to_s, :description => "#{act.to_s.capitalize} a domain" do
        display :ok

        input :domain,
            :prompt      => "Domain Name",
            :description => "Name of a defined domain",
            :type        => :string,
            :validation  => '^.+$',
            :optional    => false,
            :maxlength   => 50

        output :state,
               :description => "Domain State",
               :display_as => "State Code"

        output :state_description,
               :description => "Domain State",
               :display_as => "State"

    end
end
