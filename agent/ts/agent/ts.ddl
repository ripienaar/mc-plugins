metadata    :name        => "Task Scheduler Agent",
            :description => "An agent to create and manage jobs for Task Scheduler",
            :author      => "R.I.Pienaar <rip@devco.net>",
            :license     => "ASL2",
            :version     => "0.1",
            :url         => "http://www.devco.net/",
            :timeout     => 5

action "add", :description => "Schedules a command to be run" do
    input :command,
          :prompt      => "Command",
          :description => "Unix Command to Schedule",
          :type        => :string,
          :validation  => '^.+$',
          :optional    => false,
          :maxlength   => 150

    input :no_output,
          :prompt      => "Do not record output",
          :description => "Set to false to surpress recording the command output",
          :type        => :boolean,
          :optional    => true

    input :gzip_output,
          :prompt      => "Compress Output",
          :description => "Enable this to store the command output compressed with gzip",
          :type        => :boolean,
          :optional    => true

     input :depends_on_previous,
           :prompt      => "Dependant on previous command",
           :description => "Only run this command if the previous one completed succesfully",
           :type        => :boolean,
           :optional    => true

     output :exitcode,
            :description => "The exitcode from the ts binary",
            :display_as => "TS Exit Code"

     output :ts_jobid,
            :description => "The TS specific job id",
            :display_as => "TS Job ID"

     output :jobid,
            :description => "The ID that identifies this job uniquely across all machines",
            :display_as  => "Job ID"

     output :msg,
            :description => "Job status",
            :display_as => "Status"
end

action "query", :description => "Query the status of a previously queued command" do
    display :always

    input :jobid,
          :prompt      => "Job ID",
          :description => "The MCollective Job ID",
          :type        => :string,
          :validation  => '^.+$',
          :optional    => false,
          :maxlength   => 33

    output :output,
           :description => "Textual output from the unix command",
           :display_as => "Output"

    output :ts_jobid,
           :description => "Per Machine TS Job ID",
           :display_as => "TS Job ID"

    output :state,
           :description => "Textual representation of the job state",
           :display_as => "Job State State"

    output :error_level,
           :description => "Unix exit code for the command",
           :display_as => "Exit Code"

    output :run_time,
           :description => "Total run time for the command",
           :display_as => "Run Time"

    output :user_time,
           :description => "User time spent running the command",
           :display_as => "User Time"

    output :system_time,
           :description => "System time spent running the command",
           :display_as => "System Time"

    output :jobid,
           :description => "Collective wide unique job ID",
           :display_as => "Job ID"

    output :command,
           :description => "The command that was run",
           :display_as => "Command"
end

action "get_queue", :description => "Retrieves the entire job queue" do
    display :always

    output :queue,
           :description => "The complete Job Queue",
           :display_as => "Queue"
end
