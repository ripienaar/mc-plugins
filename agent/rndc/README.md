RNDC AGENT
===========

SimpleRPC RNDC Agent

         Author: R.I.Pienaar <rip@devco.net>
        Version: 0.1
        License: ASL2.0
        Timeout: 5
      Home Page: http://www.devco.net/



ACTIONS:
========
   * freeze
   * notify
   * querylog
   * reconfig
   * refresh
   * reload
   * retransfer
   * sign
   * status
   * thaw

_freeze_ action:
--------------
Freeze a zone or all zones

       INPUT:
           zone:
              Description: Zone to act on
                   Prompt: Zone
                     Type: string
               Validation: ^.+$
                   Length: 100


       OUTPUT:
           err:
              Description: STDERR output
               Display As: Error

           out:
              Description: STDOUT output
               Display As: Output

_notify_ action:
--------------
Notify a zone

       INPUT:
           zone:
              Description: Zone to act on
                   Prompt: Zone
                     Type: string
               Validation: ^.+$
                   Length: 100


       OUTPUT:
           err:
              Description: STDERR output
               Display As: Error

           out:
              Description: STDOUT output
               Display As: Output

_querylog_ action:
----------------
Toggles the server wide querylog


       OUTPUT:
           err:
              Description: STDERR output
               Display As: Error

           out:
              Description: STDOUT output
               Display As: Output

_reconfig_ action:
----------------
Reloads the server configuration


       OUTPUT:
           err:
              Description: STDERR output
               Display As: Error

           out:
              Description: STDOUT output
               Display As: Output

_refresh_ action:
---------------
Refresh a zone

       INPUT:
           zone:
              Description: Zone to act on
                   Prompt: Zone
                     Type: string
               Validation: ^.+$
                   Length: 100


       OUTPUT:
           err:
              Description: STDERR output
               Display As: Error

           out:
              Description: STDOUT output
               Display As: Output

_reload_ action:
--------------
Reload a zone or all zones

       INPUT:
           zone:
              Description: Zone to act on
                   Prompt: Zone
                     Type: string
               Validation: ^.+$
                   Length: 100


       OUTPUT:
           err:
              Description: STDERR output
               Display As: Error

           out:
              Description: STDOUT output
               Display As: Output

_retransfer_ action:
------------------
Retransfer a zone

       INPUT:
           zone:
              Description: Zone to act on
                   Prompt: Zone
                     Type: string
               Validation: ^.+$
                   Length: 100


       OUTPUT:
           err:
              Description: STDERR output
               Display As: Error

           out:
              Description: STDOUT output
               Display As: Output

_sign_ action:
------------
Sign a zone

       INPUT:
           zone:
              Description: Zone to act on
                   Prompt: Zone
                     Type: string
               Validation: ^.+$
                   Length: 100


       OUTPUT:
           err:
              Description: STDERR output
               Display As: Error

           out:
              Description: STDOUT output
               Display As: Output

_status_ action:
--------------
Gather server status information


       OUTPUT:
           cpus_found:
              Description: Number of CPUs Found
               Display As: CPUs

           debug_level:
              Description: Active debug level
               Display As: Debug Level

           number_of_zones:
              Description: Number of zones
               Display As: Zones

           recursive_clients:
              Description: Recursive Clients
               Display As: Recursive Clients

           soa_queries_in_progress:
              Description: Active SOA queries
               Display As: SOA Queries in Progress

           tcp_clients:
              Description: TCP Clients
               Display As: TCP Clients

           version:
              Description: Server Version
               Display As: Version

           worker_threads:
              Description: Number of Worker Threads
               Display As: Worker Threads

           xfers_deferred:
              Description: Number of Xfers deferred
               Display As: Xfers Deferred

           xfers_running:
              Description: Active transfers
               Display As: Xfers Running

_thaw_ action:
------------
Thaw a zone or all zones

       INPUT:
           zone:
              Description: Zone to act on
                   Prompt: Zone
                     Type: string
               Validation: ^.+$
                   Length: 100


       OUTPUT:
           err:
              Description: STDERR output
               Display As: Error

           out:
              Description: STDOUT output
               Display As: Output

