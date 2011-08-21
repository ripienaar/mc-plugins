What?
=====

Basic management of Libvirt Hypervisors and domains

Usage?
======

There isn't a bundled application, it works fine through the normal RPC client:

Hypervisor Information:
-----------------------
<pre>
% mco rpc libvirt hvinfo

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
     Active Domains: ["dev2_devco", "dev4_devco", "dev5_devco", "dev3_devco"]
                MHz: 1297
            Threads: 1

Finished processing 1 / 1 hosts in 103.90 ms
</pre>

Domain Information:
-------------------

<pre>
% mco rpc libvirt domaininfo domain=dev2_devco

kvm1.xx.net
        State: 1
        State: Running
         UUID: fd402bc2-9207-fb2a-d650-a3ba85214578
    Autostart: true
       Memory: 524288
        VCPUs: 1
   Max Memory: 524288
     CPU Time: 29540000000

Finished processing 1 / 1 hosts in 92.90 ms
</pre>

Manage a Domain:
----------------

<pre>
% mco rpc libvirt destroy domain=dev4_devco

kvm1.xx.net
   State: 5
   State: Shut off

Finished processing 1 / 1 hosts in 320.48 ms
</pre>

Other available actions are:

 * create / start
 * destroy
 * resume
 * shutdown
 * suspend

Todo?
====

 * Make the hypervisor URL configurable, atm only QEMU and only unauthenticated
 * Expose more hypervisor information like device lists, network lists, storage lists etc
 * Allow for creation using provided XML
 * More stats so that full feature auto provisioning can be built

Contact?
========

R.I.Pienaar / rip@devco.net / http://devco.net / @ripienaar
