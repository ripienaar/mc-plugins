What?
=====

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

    $ mco ping --dm=ec2 -F availability_zone=/eu-west/

All nodes with the tag cluster=charlie:

    $ mco ping --dm=ec2 -F tag_cluster=charlie

All nodes in the 'mcollective' security group:

    $ mco ping --dm=ec2 -C mcollective

Regular expressions are supported where sensible.

Currently for a given node this is an example of the data that you can
discover using the fact-like syntax:

    {"flavor_id"=>"m1.medium",
     "image_id"=>"ami-230b1b57",
     "state"=>"running",
     "monitoring"=>false,
     "availability_zone"=>"eu-west-1c",
     "placement_group"=>nil,
     "tenancy"=>"default",
     "id"=>"i-f4e9b0b9",
     "private_dns_name"=>"ip-10-34-192-235.eu-west-1.compute.internal",
     "dns_name"=>"ec2-54-228-117-74.eu-west-1.compute.amazonaws.com",
     "reason"=>nil,
     "key_name"=>"rip_aws",
     "ami_launch_index"=>9,
     "created_at"=>2013-06-28 10:11:57 UTC,
     "kernel_id"=>"aki-71665e05",
     "private_ip_address"=>"10.34.192.235",
     "public_ip_address"=>"54.228.117.74",
     "root_device_type"=>"ebs",
     "client_token"=>"oatGN1372414316920",
     "tag_cluster"=>"charlie"}]


Contact?
--------

R.I.Pienaar / rip@devco.net / @ripienaar / http://devco.net/

