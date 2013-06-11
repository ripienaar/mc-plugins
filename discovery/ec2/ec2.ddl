metadata    :name        => "ec2",
            :description => "EC2 Instance data based discovery",
            :author      => "R.I.Pienaar <rip@devco.net>",
            :license     => "ASL 2.0",
            :version     => "0.1",
            :url         => "http://marionette-collective.org/",
            :timeout     => 10

usage <<-END_OF_USAGE
A discovery plugin that uses fog.io to discover against the EC2 API.

In order to configure it you need a standard ~/.fog file that sets
up your EC2 credentials etc.

You can set plugin.ec2.region in the MCollective configuration to choose
your region else it will use eu-west-1

This plugin maps instance attributes to facts, instance security group
names to classes and instance tags are turned into facts with the tag_
prefixed.

The discovered names will be the instance private dns name and your
mcollective identities should match.

All nodes in eu-west:

   $ mco ping --dm=ec -F availability_zone=/eu-west/

All nodes with the tag cluster=charlie:

   $ mco ping --dm=ec2 -F tag_cluster=charlie

All nodes in the 'mcollective' security group:

   $ mco ping --dm=ec2 -C mcollective

Regular expressions are supported where sensible.
END_OF_USAGE

discovery do
    capabilities [:classes, :facts, :identity]
end
