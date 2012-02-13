A mco plugin that uses discovery to feed host lists
to capistrano:

     mco cap invoke -W dom0=kvm1 COMMAND="service mcollective restart" -- -s user=root

Above will discover all nodes matching _dom0=kvm1_ and restart mcollective on them as the root user.
