metadata    :name        => "eximng",
            :description => "SimpleRPC based Exim management agent",
            :author      => "R.I.Pienaar <rip@devco.net>",
            :license     => "ASL2",
            :version     => "0.2",
            :url         => "http://www.devco.net/",
            :timeout     => 30

action "mailq", :description => "Retrieves the server mail queue" do
    display :always

    input :limit_sender,
          :prompt      => "Sender",
          :description => "Limit to messages matching supplied sender",
          :type        => :string,
          :validation  => '^.+$',
          :optional    => true,
          :maxlength   => 50

    input :limit_recipient,
          :prompt      => "Recipient",
          :description => "Limit to messages matching supplied recipient",
          :type        => :string,
          :validation  => '^.+$',
          :optional    => true,
          :maxlength   => 50

    input :limit_younger_than,
          :prompt      => "Maximum Age",
          :description => "Limit to messages newer than supplied",
          :type        => :string,
          :validation  => '^\d+$',
          :optional    => true,
          :maxlength   => 6

    input :limit_older_than,
          :prompt      => "Minimum Age",
          :description => "Limit to messages older than supplied",
          :type        => :string,
          :validation  => '^\d+$',
          :optional    => true,
          :maxlength   => 6

    input :limit_frozen_only,
          :prompt      => "Frozen Only",
          :description => "Limits the function to frozen messages only",
          :type        => :boolean,
          :optional    => true

    input :limit_unfrozen_only,
          :prompt      => "Unfrozen Only",
          :description => "Limits the function to unfrozen messages only",
          :type        => :boolean,
          :optional    => true

    output :mailq,
           :description => "Server Mail Queue",
           :display_as  => "Mail Queue:"

    output :size,
           :description => "Mail Queue Size",
           :display_as  => "Size"

    output :frozen,
           :description => "Frozen Messages",
           :display_as  => "Frozen"

    summarize do
        aggregate sum(:size), :format => "   Total Email: %d"
    end
end

action "size", :description => "Retrieve mail queue size statistics" do
    display :always

    input :limit_sender,
          :prompt      => "Sender",
          :description => "Limit to messages matching supplied sender",
          :type        => :string,
          :validation  => '^.+$',
          :optional    => true,
          :maxlength   => 50

    input :limit_recipient,
          :prompt      => "Recipient",
          :description => "Limit to messages matching supplied recipient",
          :type        => :string,
          :validation  => '^.+$',
          :optional    => true,
          :maxlength   => 50

    input :limit_younger_than,
          :prompt      => "Maximum Age",
          :description => "Limit to messages newer than supplied",
          :type        => :string,
          :validation  => '^\d+$',
          :optional    => true,
          :maxlength   => 6

    input :limit_older_than,
          :prompt      => "Minimum Age",
          :description => "Limit to messages older than supplied",
          :type        => :string,
          :validation  => '^\d+$',
          :optional    => true,
          :maxlength   => 6

    input :limit_frozen_only,
          :prompt      => "Frozen Only",
          :description => "Limits the function to frozen messages only",
          :type        => :boolean,
          :optional    => true

    input :limit_unfrozen_only,
          :prompt      => "Unfrozen Only",
          :description => "Limits the function to unfrozen messages only",
          :type        => :boolean,
          :optional    => true

    output :total,
           :description => "Total messages in the queue",
           :display_as  => "Total"

    output :matched,
           :description => "Matched messages in the queue",
           :display_as  => "Matched"

    output :frozen,
           :description => "Frozen messages in the queue",
           :display_as  => "Frozen"
end

action "summarytext", :description => "Textual report for exiqsumm" do
    display :always

    output :summary,
           :description => "Mail Queue Summary",
           :display_as  => "Summary"
end

action "retrymsg", :description => "Retries a specific message" do
    display :ok

    input :msgid,
          :prompt      => "Message ID",
          :description => "Valid message id currently in the mail queue",
          :type        => :string,
          :validation  => :exim_msgid,
          :optional    => false,
          :maxlength   => 16

    output :status,
           :description => "Status Message",
           :display_as  => "Status"
end

action "addrecipient", :description => "Add a recipient to a message" do
    display :ok

    input :msgid,
          :prompt      => "Message ID",
          :description => "Valid message id currently in the mail queue",
          :type        => :string,
          :validation  => :exim_msgid,
          :optional    => false,
          :maxlength   => 16

    input :recipient,
          :prompt      => "Recipient",
          :description => "Recipient email address",
          :type        => :string,
          :validation  => '^.+$',
          :optional    => false,
          :maxlength   => 50

    output :status,
           :description => "Status Message",
           :display_as  => "Status"
end

action "setsender", :description => "Sets the sender email address of a message" do
    display :ok

    input :msgid,
          :prompt      => "Message ID",
          :description => "Valid message id currently in the mail queue",
          :type        => :string,
          :validation  => :exim_msgid,
          :optional    => false,
          :maxlength   => 16

    input :sender,
          :prompt      => "Sender",
          :description => "Sender email address",
          :type        => :string,
          :validation  => '^.+$',
          :optional    => false,
          :maxlength   => 50

    output :status,
           :description => "Status Message",
           :display_as => "Status"
end

action "markdelivered", :description => "Marks a specific message as delivered" do
    display :ok

    input :msgid,
          :prompt      => "Message ID",
          :description => "Valid message id currently in the mail queue",
          :type        => :string,
          :validation  => :exim_msgid,
          :optional    => false,
          :maxlength   => 16

    input :recipient,
          :prompt      => "Recipient",
          :description => "Recipient email address",
          :type        => :string,
          :validation  => '^.+$',
          :optional    => true,
          :maxlength   => 50

    output :status,
           :description => "Status Message",
           :display_as  => "Status"
end

action "exigrep", :description => "Grep the main log for lines associated with a pattern" do
    display :ok

    input :pattern,
          :prompt      => "Pattern",
          :description => "Pattern to search for",
          :type        => :string,
          :validation  => '^.+$',
          :optional    => false,
          :maxlength   => 100

    output :matches,
           :description => "Lines matched in the log",
           :display_as  => "Matches"
end

action "freeze", :description => "Freeze a specific message" do
    display :ok

    input :msgid,
          :prompt      => "Message ID",
          :description => "Valid message id currently in the mail queue",
          :type        => :string,
          :validation  => :exim_msgid,
          :optional    => false,
          :maxlength   => 16

    output :status,
           :description => "Status Message",
           :display_as => "Status"
end

action "thaw", :description => "Thaw a specific message" do
    display :ok

    input :msgid,
          :prompt      => "Message ID",
          :description => "Valid message id currently in the mail queue",
          :type        => :string,
          :validation  => :exim_msgid,
          :optional    => false,
          :maxlength   => 16

    output :status,
           :description => "Status Message",
           :display_as  => "Status"
end

action "giveup", :description => "Gives up on a specific message with a NDR" do
    display :ok

    input :msgid,
          :prompt      => "Message ID",
          :description => "Valid message id currently in the mail queue",
          :type        => :string,
          :validation  => :exim_msgid,
          :optional    => false,
          :maxlength   => 16

    output :status,
           :description => "Status Message",
           :display_as  => "Status"
end

action "rm", :description => "Removes a specific message without a NDR" do
    display :always

    input :msgid,
          :prompt      => "Message ID",
          :description => "Valid message id currently in the mail queue",
          :type        => :string,
          :validation  => :exim_msgid,
          :optional    => false,
          :maxlength   => 16

    output :status,
           :description => "Status Message",
           :display_as  => "Status"
end

action "exiwhat", :description => "Retrieves text from the exiwhat command" do
    display :always

    output :exiwhat,
           :description => "Output from exiwhat",
           :display_as => "Exiwhat"
end

action "rmbounces", :description => "Removes postmaster originated mail" do
    display :always

    output :output,
           :description => "Output from exim",
           :display_as  => "Output"

    output :status,
           :description => "Status Message",
           :display_as  => "Status"

    output :count,
           :description => "Amount of messages removed",
           :display_as  => "Count"
end

action "rmfrozen", :description => "Removes frozen mail" do
    display :always

    output :output,
           :description => "Output from exim",
           :display_as  => "Output"

    output :status,
           :description => "Status Message",
           :display_as  => "Status"

    output :count,
           :description => "Amount of messages removed",
           :display_as  => "Count"
end

action "runq", :description => "Schedules a normal queue run" do
    output :status,
           :description => "Status Message",
           :display_as  => "Status"
end

action "delivermatching", :description => "Schedules a delivery attempt for all mail matching a pattern" do
    input :pattern,
          :prompt      => "Pattern",
          :description => "Address pattern to deliver",
          :type        => :string,
          :validation  => '^.+$',
          :optional    => false,
          :maxlength   => 80

    output :status,
           :description => "Status Message",
           :display_as  => "Status"
end

action "testaddress", :description => "Do a routing test for a specific email address" do
     display :always

     input :address,
           :prompt      => "Address",
           :description => "Address to test",
           :type        => :string,
           :validation  => '^.+$',
           :optional    => false,
           :maxlength   => 50

    output :routing_information,
           :description => "Routing Information",
           :display_as  => "Route"
end
