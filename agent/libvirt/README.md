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
                Max VCPUs: 16
                  Secrets: 0
                     Type: QEMU
                  Version: 12001
           Active Domains: ["dev2_devco", "dev3_devco", "dev4_devco", "dev5_devco"]
                      MHz: 1297
          Active Networks: 1
         Inactive Domains: 0
         Inactive Domains: []
   Inactive Storage Pools: 0
                  Sockets: 1
           Active Domains: 4
     Active Storage Pools: 1
                    Cores: 2
                    Model: x86_64
      Inactive Interfaces: 0
               Numa Nodes: 1
                      URI: qemu:///system
             Node Devices: 49
        Active Interfaces: 2
                   Memory: 8063656
          Network Filters: 15
              Free Memory: 3993661440
                     CPUs: 2
        Inactive Networks: 0
                  Threads: 1
</pre>

<pre>
% mco virt info dev2_devco

kvm1.xx.net
                  UUID: ca74dc32-0f09-7265-b67e-151b4fb5dd90
            State Code: 1
             Autostart: false
               OS Type: 0
                 VCPUs: 1
             Snapshots: []
            Max Memory: 524288
            Persistent: true
   Number of Snapshots: 0
              CPU Time: 5594920000000
                Memory: 524288
      Current Snapshot: false
                 State: Running
          Managed Save: false
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
 * stop (needs acpid in the domain)
 * reboot (needs acpid in the domain)
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

List all Domains:
-----------------

<pre>
% mco virt domains

           xen1.xx.net:    Domain-0, devco_net
           kvm1.xx.net:    dev2_devco, dev3_devco, dev4_devco, dev5_devco
           xen5.xx.net:    Domain-0, dev1_devco
</pre>

Find a Domain:
--------------

Searches for a domain based on a ruby pattern:

<pre>
% mco virt find devco

           xen1.xx.net:    devco_net
           kvm1.xx.net:    dev2_devco, dev3_devco, dev4_devco, dev5_devco
           xen5.xx.net:    dev1_devco
</pre>


Todo?
====

 * More stats so that full feature auto provisioning can be built

Contact?
========

R.I.Pienaar / rip@devco.net / http://devco.net / @ripienaar
