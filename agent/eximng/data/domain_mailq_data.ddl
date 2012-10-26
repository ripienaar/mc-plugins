metadata    :name        => "domain_mailq_data",
            :description => "Checks the mailq for mail to a certain domain",
            :author      => "R.I.Pienaar <rip@devco.net>",
            :license     => "ASL 2.0",
            :version     => "0.1",
            :url         => "http:/devco.net/",
            :timeout     => 1

dataquery :description => "Counts the mail destined for a certain domain" do
    input :query,
          :prompt      => "Domain",
          :description => "Domain to check the mail queue for",
          :type        => :string,
          :validation  => :shellsafe,
          :optional    => false,
          :maxlength   => 50

    output :size,
           :description => "Amount of mail matching the domain in the spool",
           :display_as  => "Size",
           :default     => 0
end
