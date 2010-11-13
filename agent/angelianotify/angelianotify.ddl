metadata    :name        => "SimpleRPC Plugin for The Nagelia Nagios Notifier",
            :description => "Agent to send messages via angelia",
            :author      => "R.I.Pienaar",
            :license     => "Apache License 2.0",
            :version     => "1.3",
            :url         => "http://mcollective-plugins.googlecode.com/",
            :timeout     => 2

action "sendmsg", :description => "Send a message" do
    input :recipient,
          :prompt      => "Recipient",
          :description => "Message Recipient",
          :type        => :string,
          :validation  => '^\w+\:\/\/',
          :optional    => false,
          :maxlength   => 120

    input :subject,
          :prompt      => "Subject",
          :description => "Message Subject",
          :type        => :string,
          :validation  => '.+',
          :optional    => true,
          :maxlength   => 120

    input :message,
          :prompt      => "Message",
          :description => "Message Body",
          :type        => :string,
          :validation  => '.+',
          :optional    => false,
          :maxlength   => 5000


    output :msg,
          :description => "Status message",
          :display_as  => "Delivery Status"
end

