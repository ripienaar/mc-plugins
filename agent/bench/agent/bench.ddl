metadata    :name        => "bench",
            :description => "Manage multiple mcollectived instances on a single node",
            :author      => "R.I.Pienaar",
            :license     => "ASL 2.0",
            :version     => "0.6",
            :url         => "http://devco.net/",
            :timeout     => 30

action "destroy", :description => "Stop and destroy all members" do
    display :always

    output :instance_count,
           :description => "Number of managed instances",
           :display_as => "Instances"

    output :instances_running,
           :description => "Number of instances currently running",
           :display_as => "Running"

    output :instances_stopped,
           :description => "Number of instances currently stopped",
           :display_as => "Stopped"

    summarize do
        aggregate sum(:instance_count, :format => "Total Instances: %d")
    end
end

action "create_members", :description => "Create new member servers" do
    input :count,
          :prompt      => "Instance Count",
          :description => "Number of instances to create",
          :type        => :number,
          :optional    => false

    input :activemq_host,
          :prompt      => "ActiveMQ host",
          :description => "Connect to a specific ActiveMQ host",
          :type        => :string,
          :validation  => '^.+$',
          :maxlength   => 50,
          :optional    => true

    output :status,
           :description => "Command exit code",
           :display_as => "Exit Code"

    output :instance_count,
           :description => "Number of managed instances",
           :display_as => "Instances"

    output :instances_running,
           :description => "Number of instances currently running",
           :display_as => "Running"

    output :instances_stopped,
           :description => "Number of instances currently stopped",
           :display_as => "Stopped"

    summarize do
        aggregate sum(:instance_count, :format => "Total Instances: %d")
    end
end

action "list", :description => "Names of known member servers" do
    display :always

    output :members,
           :description => "Known collective members",
           :display_as => "Members"
end

action "status", :description => "Status of all known member servers" do
    display :always

    output :members,
           :description => "Known collective members",
           :display_as => "Members"

    output :instance_count,
           :description => "Number of managed instances",
           :display_as => "Instances"

    output :instances_running,
           :description => "Number of instances currently running",
           :display_as => "Running"

    output :instances_stopped,
           :description => "Number of instances currently stopped",
           :display_as => "Stopped"

    summarize do
        aggregate sum(:instance_count, :format => "Total Instances: %d")
        aggregate sum(:instances_running, :format => "Total Running Instances: %d")
        aggregate sum(:instances_stopped, :format => "Total Stopped Instances: %d")
    end
end

action "start", :description => "Start all known member servers" do
    display :always

    output :instance_count,
           :description => "Number of managed instances",
           :display_as => "Instances"

    output :instances_running,
           :description => "Number of instances currently running",
           :display_as => "Running"

    output :instances_stopped,
           :description => "Number of instances currently stopped",
           :display_as => "Stopped"

    summarize do
        aggregate sum(:instance_count, :format => "Total Instances: %d")
        aggregate sum(:instances_running, :format => "Total Running Instances: %d")
        aggregate sum(:instances_stopped, :format => "Total Stopped Instances: %d")
    end
end

action "stop", :description => "Stop all known member servers" do
    display :always

    output :instance_count,
           :description => "Number of managed instances",
           :display_as => "Instances"

    output :instances_running,
           :description => "Number of instances currently running",
           :display_as => "Running"

    output :instances_stopped,
           :description => "Number of instances currently stopped",
           :display_as => "Stopped"

    summarize do
        aggregate sum(:instance_count, :format => "Total Instances: %d")
        aggregate sum(:instances_running, :format => "Total Running Instances: %d")
        aggregate sum(:instances_stopped, :format => "Total Stopped Instances: %d")
    end
end
