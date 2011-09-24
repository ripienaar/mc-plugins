metadata    :name        => "libvirt",
            :description => "SimpleRPC Libvirt Agent",
            :author      => "R.I.Pienaar <rip@devco.net>",
            :license     => "ASL2.0",
            :version     => "0.2",
            :url         => "http://devco.net/",
            :timeout     => 10

action "hvinfo", :description => "Hypervisor Information" do
    display :always

    input :facts,
        :prompt      => "Include Facts?",
        :description => "Also include Facter in the reply",
        :type        => :boolean,
        :optional    => true

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

    output :num_of_defined_domains,
           :description => "Number of inactive domains",
           :display_as => "Inactive Domains"

    output :num_of_domains,
           :description => "Number of active domains",
           :display_as => "Active Domains"

    output :num_of_defined_interfaces,
           :description => "Number of inactive interfaces",
           :display_as => "Inactive Interfaces"

    output :num_of_interfaces,
           :description => "Number of active interfaces",
           :display_as => "Active Interfaces"

    output :num_of_defined_networks,
           :description => "Number of inactive networks",
           :display_as => "Inactive Networks"

    output :num_of_networks,
           :description => "Number of active networks",
           :display_as => "Active Networks"

    output :num_of_defined_storage_pools,
           :description => "Number of inactive storage pools",
           :display_as => "Inactive Storage Pools"

    output :num_of_storage_pools,
           :description => "Active storage pools",
           :display_as => "Active Storage Pools"

    output :num_of_nodedevices,
           :description => "Number of active node devices",
           :display_as => "Node Devices"

    output :num_of_nwfilters,
           :description => "Number of network filters",
           :display_as => "Network Filters"

    output :num_of_secrets,
           :description => "Number of secrets",
           :display_as => "Secrets"

    output :facts,
           :description => "Facts about this machine",
           :display_as  => "Facts"
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

    output :persistent,
           :description => "Is the domain Persistent",
           :display_as => "Persistent"

    output :snapshots,
           :description => "List of current snapshots",
           :display_as => "Snapshots"

    output :num_of_snapshots,
           :description => "Number of snapshots",
           :display_as => "Number of Snapshots"

    output :has_current_snapshot,
           :description => "Does the domain have a current snapshot",
           :display_as => "Current Snapshot"

    output :has_managed_save,
           :description => "Does the domain have a managed save",
           :display_as => "Managed Save"

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

    input :xmlfile,
        :prompt      => "XML File",
        :description => "Libvirt XML file",
        :type        => :string,
        :validation  => '^.+$',
        :optional    => true,
        :maxlength   => 200

    input :xml,
        :prompt      => "XML Definition",
        :description => "Libvirt XML",
        :type        => :string,
        :validation  => '^.+$',
        :optional    => true,
        :maxlength   => 0

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

[:destroy, :shutdown, :suspend, :resume, :create, :start, :reboot].each do |act|
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
