What?
=====

Basic management of Libvirt Hypervisors and domains

Usage?
======

An mco application is included that wraps arond the basic capabilities of the agent
for full details see _mco virt --help_

You need the ruby libvirt bindings installed, tested with version 0.3.0

Hypervisor / Domain Information:
-----------------------
<pre>
% mco virt info

kvm1.xx.net
   Inactive Domains: []
               Type: QEMU
            Sockets: 1
          Max VCPUs: 16
              Cores: 2
              Model: x86_64
                URI: qemu:///system
            Version: 12001
             Memory: 8063656
         Numa Nodes: 1
        Free Memory: 2292154368
               CPUs: 2
     Active Domains: ["dev2_devco", "dev3_devco", "dev4_devco", "dev5_devco"]
                MHz: 1297
            Threads: 1
</pre>

<pre>
% mco virt info dev2_devco

kvm1.xx.net
        State: 1
   Max Memory: 524288
       Memory: 524288
     CPU Time: 35180000000
        State: Running
         UUID: ca74dc32-0f09-7265-b67e-151b4fb5dd90
    Autostart: false
        VCPUs: 1
</pre>

Manage a Domain:
----------------

<pre>
% mco virt stop dev4_devco

kvm1.xx.net
   State: 5
   State: Shut off
</pre>

Other available actions are:

 * start
 * stop
 * suspend
 * resume
 * destroy

Create a Domain:
----------------

This requires you to have created the XML that describes the domain
on the node already.  The _permanent_ argument is optional and is the
difference between _virsh define_ and _virsh create_.

<pre>
% mco virt define dev4 /srv/kvm/etc/dev4.xml permanent

   State Code: 1
        State: Running
</pre>

Undefine a Domain:
------------------

This undefines a domain, you can optionally destroy the domain before
undefining it else the request will fail.

<pre>
% mco virt undefine dev4 destroy
</pre>

Todo?
====

 * Expose more hypervisor information like device lists, network lists, storage lists etc
 * More stats so that full feature auto provisioning can be built

Contact?
========

R.I.Pienaar / rip@devco.net / http://devco.net / @ripienaar
