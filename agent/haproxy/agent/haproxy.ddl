metadata :name => "haproxy",
         :description => "Manage HAProxy through it's socket interface",
         :author => "R.I.Pienaar <rip@devco.net>",
         :license => "ASL2.0",
         :version => "0.1",
         :url => "http://devco.net",
         :timeout => 1

requires :mcollective => "2.2.1"

action "enable", :description => "Enables a server for a specific backend" do
    input :backend,
          :prompt      => "Backend",
          :description => "Backend name",
          :type        => :string,
          :validation  => '^[a-zA-Z\d_]+$',
          :optional    => false,
          :maxlength   => 20

     input :server,
           :prompt      => "Server",
           :description => "Server name",
           :type        => :string,
           :validation  => '^[a-zA-Z\d_]+$',
           :optional    => false,
           :maxlength   => 20

    output :status,
           :description => "Message from HAProxy if any",
           :display_as  => "Status",
           :default     => "OK"
end

action "disable", :description => "Disables a server for a specific backend" do
    input :backend,
          :prompt      => "Backend",
          :description => "Backend name",
          :type        => :string,
          :validation  => '^[a-zA-Z\d_]+$',
          :optional    => false,
          :maxlength   => 20

     input :server,
           :prompt      => "Server",
           :description => "Server name",
           :type        => :string,
           :validation  => '^[a-zA-Z\d_]+$',
           :optional    => false,
           :maxlength   => 20

    output :status,
           :description => "Message from HAProxy if any",
           :display_as  => "Status",
           :default     => "OK"
end
