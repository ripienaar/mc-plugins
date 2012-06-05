metadata    :name        => "collective",
            :description => "Manage multiple mcollectived instances on a single node",
            :author      => "R.I.Pienaar",
            :license     => "ASL 2.0",
            :version     => "0.6",
            :url         => "http://devco.net/",
            :timeout     => 120

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
end

action "clone_source_repo", :description => "Clone a git repo to use as source for the collective" do
    input :gitrepo,
          :prompt      => "Git Repository",
          :description => "Any valid git repository path",
          :type        => :string,
          :validation  => '^.+$',
          :optional    => false,
          :maxlength    => 120

    input :branch,
          :prompt      => "Branch",
          :description => "Branch to check out",
          :type        => :string,
          :validation  => '^.+$',
          :optional    => false,
          :maxlength    => 50

    output :status,
           :description => "Command exit code",
           :display_as => "Exit Code"
end

action "create_members", :description => "Create new member servers" do
    input :count,
          :prompt      => "Instance Count",
          :description => "Number of instances to create",
          :type        => :number,
          :optional    => false

     input :version,
           :prompt      => "Version",
           :description => "Git tag to check out",
           :type        => :string,
           :validation  => '^.+$',
           :optional    => false,
           :maxlength   => 50

     input :colllective,
           :prompt      => "Main Collective",
           :description => "The main collective the instances will belong to",
           :type        => :string,
           :validation  => '^\w+$',
           :optional    => false,
           :maxlength   => 20

     input :subcollective,
           :prompt      => "Subcollectives",
           :description => "Comma seperated list of sub collectives",
           :type        => :string,
           :validation  => '^[\w,]+$',
           :optional    => false,
           :maxlength   => 100

     input :server,
           :prompt      => "ActiveMQ Server",
           :description => "ActiveMQ broker to connect to",
           :type        => :string,
           :validation  => '^[\w\.,]+$',
           :optional    => false,
           :maxlength   => 50

     input :port,
           :prompt      => "ActiveMQ Port",
           :description => "ActiveMQ broker port to connect to",
           :type        => :integer,
           :validation  => '^\d+$',
           :optional    => false,
           :maxlength    => 20

     input :user,
           :prompt      => "ActiveMQ User",
           :description => "User to use when connecting to the broker",
           :type        => :string,
           :validation  => '^.+$',
           :optional    => false,
           :maxlength    => 20

     input :password,
           :prompt      => "ActiveMQ Password",
           :description => "Password to use when connecting to the broker",
           :type        => :string,
           :validation  => '^.+$',
           :optional    => false,
           :maxlength    => 20

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
end
