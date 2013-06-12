What?
=====

A MCollective agent that can be deployed into an existing mcollective
setup and be used to start up multiple instances of mcollective on
each node.

The purpose is to assist in scale testing middleware, given 100 VMs
you could comfortably start up to 1000 or even 1500 mcollective
instances.


Creating Instances?
-------------------

Prior to creating instances we need to be sure there are no previous
instances running:

    $ mco rpc bench destroy
    Discovering hosts using the mc method for 2 second(s) .... 1

     * [ ============================================================> ] 1 / 1


    master.example.com
       Instances: 0
         Running: 0
         Stopped: 0

    Summary of Instances:

       Total Instances: 0

    Finished processing 1 / 1 hosts in 75.92 ms

You're now ready to create new instances which will share libdir,
brokers etc all with your original mcollectived:

    $ mco rpc bench create_members count=10
    Discovering hosts using the mc method for 2 second(s) .... 1

     * [ ============================================================> ] 1 / 1

    Summary of Instances:

       Total Instances: 10

    Finished processing 1 / 1 hosts in 94.48 ms

I recommend you test against a different ActiveMQ instance though so that
when you reach the capacity limit of your ActiveMQ instance under test you
can use the first one to destroy the bench collective:

    $ mco rpc bench create_members count=10 activemq_host=another.host.example.net

Instance Status?
----------------

You can figure out the status of your bench instances:

    $ mco rpc bench status
    Discovering hosts using the mc method for 2 second(s) .... 1

     * [ ============================================================> ] 1 / 1


    master.example.com
       Instances: 10
         Running: 0
         Stopped: 10
         Members: [{:name=>"master.example.com-2", :pid=>nil},
                   {:name=>"master.example.com-8", :pid=>nil},
                   {:name=>"master.example.com-1", :pid=>nil},
                   {:name=>"master.example.com-7", :pid=>nil},
                   {:name=>"master.example.com-6", :pid=>nil},
                   {:name=>"master.example.com-3", :pid=>nil},
                   {:name=>"master.example.com-5", :pid=>nil},
                   {:name=>"master.example.com-9", :pid=>nil},
                   {:name=>"master.example.com-4", :pid=>nil},
                   {:name=>"master.example.com-0", :pid=>nil}]

    Summary of Instances:

       Total Instances: 10

    Summary of Running:

       Total Running Instances: 0

    Summary of Stopped:

       Total Stopped Instances: 10

    Finished processing 1 / 1 hosts in 84.50 ms

Here they are all created but none of them are running.

Starting the instances?
-----------------------

Starting instances take a while because we sleep a bit between starting each
one...

    $ mco rpc bench start
    Discovering hosts using the mc method for 2 second(s) .... 1

     * [ ============================================================> ] 1 / 1


    master.example.com
       Instances: 10
         Running: 10
         Stopped: 0

    Summary of Instances:

       Total Instances: 10

    Summary of Running:

       Total Running Instances: 10

    Summary of Stopped:

       Total Stopped Instances: 0

    Finished processing 1 / 1 hosts in 9627.61 ms

If you set them up to run against the same ActiveMQ you should be able to
'mco ping' them, if on another ActiveMQ you should create a specific client.cfg
file that points to that ActiveMQ at which point you should be able to ping the
new nodes:

    $ mco ping
    master.example.com-2                     time=333.55 ms
    master.example.com-1                     time=364.56 ms
    master.example.com                       time=368.11 ms
    master.example.com-7                     time=369.92 ms
    master.example.com-8                     time=371.39 ms
    master.example.com-6                     time=372.80 ms
    master.example.com-3                     time=378.14 ms
    master.example.com-0                     time=379.62 ms
    master.example.com-9                     time=381.37 ms
    master.example.com-5                     time=382.68 ms
    master.example.com-4                     time=383.93 ms

Here we share a single ActiveMQ so both the original and the bench instances show
up

Stopping the test?
------------------

Simply destroy the bench suite to get back where you started:


    $ mco rpc bench destroy
    Discovering hosts using the mc method for 2 second(s) .... 1

     * [ ============================================================> ] 1 / 1


    master.example.com
       Instances: 0
         Running: 0
         Stopped: 0

    Summary of Instances:

       Total Instances: 0

    Finished processing 1 / 1 hosts in 75.92 ms
