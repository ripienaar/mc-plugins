EXIM NG AGENT
==============

SimpleRPC based Exim management agent

         Author: R.I.Pienaar <rip@devco.net>
        Version: 0.1
        License: ASL2
        Timeout: 30
      Home Page: http://www.devco.net/



ACTIONS:
========
   * addrecipient
   * delivermatching
   * exigrep
   * exiwhat
   * freeze
   * giveup
   * mailq
   * markdelivered
   * retrymsg
   * rm
   * rmbounces
   * rmfrozen
   * runq
   * setsender
   * size
   * summarytext
   * testaddress
   * thaw

_addrecipient_ action:
--------------------
Add a recipient to a message

       INPUT:
           msgid:
              Description: Valid message id currently in the mail queue
                   Prompt: Message ID
                     Type: string
               Validation: ^\w+-\w+-\w+$
                   Length: 16

           recipient:
              Description: Recipient email address
                   Prompt: Recipient
                     Type: string
               Validation: ^.+$
                   Length: 50


       OUTPUT:
           status:
              Description: Status Message
               Display As: Status

_delivermatching_ action:
-----------------------
Schedules a delivery attempt for all mail matching a pattern

       INPUT:
           pattern:
              Description: Address pattern to deliver
                   Prompt: Pattern
                     Type: string
               Validation: ^.+$
                   Length: 80


       OUTPUT:
           status:
              Description: Status Message
               Display As: Status

_exigrep_ action:
---------------
Grep the main log for lines associated with a pattern

       INPUT:
           pattern:
              Description: Pattern to search for
                   Prompt: Pattern
                     Type: string
               Validation: ^.+$
                   Length: 100


       OUTPUT:
           matches:
              Description: Lines matched in the log
               Display As: Matches

_exiwhat_ action:
---------------
Retrieves text from the exiwhat command


       OUTPUT:
           exiwhat:
              Description: Output from exiwhat
               Display As: Exiwhat

_freeze_ action:
--------------
Freeze a specific message

       INPUT:
           msgid:
              Description: Valid message id currently in the mail queue
                   Prompt: Message ID
                     Type: string
               Validation: ^\w+-\w+-\w+$
                   Length: 16


       OUTPUT:
           status:
              Description: Status Message
               Display As: Status

_giveup_ action:
--------------
Gives up on a specific message with a NDR

       INPUT:
           msgid:
              Description: Valid message id currently in the mail queue
                   Prompt: Message ID
                     Type: string
               Validation: ^\w+-\w+-\w+$
                   Length: 16


       OUTPUT:
           status:
              Description: Status Message
               Display As: Status

_mailq_ action:
-------------
Retrieves the server mail queue

       INPUT:
           limit_frozen_only:
              Description: Limits the function to frozen messages only
                   Prompt: Frozen Only
                     Type: boolean

           limit_older_than:
              Description: Limit to messages older than supplied
                   Prompt: Minimum Age
                     Type: string
               Validation: ^\d+$
                   Length: 6

           limit_recipient:
              Description: Limit to messages matching supplied recipient
                   Prompt: Recipient
                     Type: string
               Validation: ^.+$
                   Length: 50

           limit_sender:
              Description: Limit to messages matching supplied sender
                   Prompt: Sender
                     Type: string
               Validation: ^.+$
                   Length: 50

           limit_unfrozen_only:
              Description: Limits the function to unfrozen messages only
                   Prompt: Unfrozen Only
                     Type: boolean

           limit_younger_than:
              Description: Limit to messages newer than supplied
                   Prompt: Maximum Age
                     Type: string
               Validation: ^\d+$
                   Length: 6


       OUTPUT:
           frozen:
              Description: Frozen Messages
               Display As: Frozen

           mailq:
              Description: Server Mail Queue
               Display As: Mail Queue:

           size:
              Description: Mail Queue Size
               Display As: Size

_markdelivered_ action:
---------------------
Retries a specific message

       INPUT:
           msgid:
              Description: Valid message id currently in the mail queue
                   Prompt: Message ID
                     Type: string
               Validation: ^\w+-\w+-\w+$
                   Length: 16

           recipient:
              Description: Recipient email address
                   Prompt: Recipient
                     Type: string
               Validation: ^.+$
                   Length: 50


       OUTPUT:
           status:
              Description: Status Message
               Display As: Status

_retrymsg_ action:
----------------
Retries a specific message

       INPUT:
           msgid:
              Description: Valid message id currently in the mail queue
                   Prompt: Message ID
                     Type: string
               Validation: ^\w+-\w+-\w+$
                   Length: 16


       OUTPUT:
           status:
              Description: Status Message
               Display As: Status

_rm_ action:
----------
Removes a specific message without a NDR

       INPUT:
           msgid:
              Description: Valid message id currently in the mail queue
                   Prompt: Message ID
                     Type: string
               Validation: ^\w+-\w+-\w+$
                   Length: 16


       OUTPUT:
           status:
              Description: Status Message
               Display As: Status

_rmbounces_ action:
-----------------
Removes postmaster originated mail


       OUTPUT:
           count:
              Description: Amount of messages removed
               Display As: Count

           output:
              Description: Output from exim
               Display As: Output

           status:
              Description: Status Message
               Display As: Status

_rmfrozen_ action:
----------------
Removes frozen mail


       OUTPUT:
           count:
              Description: Amount of messages removed
               Display As: Count

           output:
              Description: Output from exim
               Display As: Output

           status:
              Description: Status Message
               Display As: Status

_runq_ action:
------------
Schedules a normal queue run


       OUTPUT:
           status:
              Description: Status Message
               Display As: Status

_setsender_ action:
-----------------
Sets the sender email address of a message

       INPUT:
           msgid:
              Description: Valid message id currently in the mail queue
                   Prompt: Message ID
                     Type: string
               Validation: ^\w+-\w+-\w+$
                   Length: 16

           sender:
              Description: Sender email address
                   Prompt: Sender
                     Type: string
               Validation: ^.+$
                   Length: 50


       OUTPUT:
           status:
              Description: Status Message
               Display As: Status

_size_ action:
------------
Retrieve mail queue size statistics

       INPUT:
           limit_frozen_only:
              Description: Limits the function to frozen messages only
                   Prompt: Frozen Only
                     Type: boolean

           limit_older_than:
              Description: Limit to messages older than supplied
                   Prompt: Minimum Age
                     Type: string
               Validation: ^\d+$
                   Length: 6

           limit_recipient:
              Description: Limit to messages matching supplied recipient
                   Prompt: Recipient
                     Type: string
               Validation: ^.+$
                   Length: 50

           limit_sender:
              Description: Limit to messages matching supplied sender
                   Prompt: Sender
                     Type: string
               Validation: ^.+$
                   Length: 50

           limit_unfrozen_only:
              Description: Limits the function to unfrozen messages only
                   Prompt: Unfrozen Only
                     Type: boolean

           limit_younger_than:
              Description: Limit to messages newer than supplied
                   Prompt: Maximum Age
                     Type: string
               Validation: ^\d+$
                   Length: 6


       OUTPUT:
           frozen:
              Description: Frozen messages in the queue
               Display As: Frozen

           matched:
              Description: Matched messages in the queue
               Display As: Matched

           total:
              Description: Total messages in the queue
               Display As: Total

_summarytext_ action:
-------------------
Textual report for exiqsumm


       OUTPUT:
           summary:
              Description: Mail Queue Summary
               Display As: Summary

_testaddress_ action:
-------------------
Do a routing test for a specific email address

       INPUT:
           address:
              Description: Address to test
                   Prompt: Address
                     Type: string
               Validation: ^.+$
                   Length: 50


       OUTPUT:
           routing_information:
              Description: Routing Information
               Display As: Route

_thaw_ action:
------------
Thaw a specific message

       INPUT:
           msgid:
              Description: Valid message id currently in the mail queue
                   Prompt: Message ID
                     Type: string
               Validation: ^\w+-\w+-\w+$
                   Length: 16


       OUTPUT:
           status:
              Description: Status Message
               Display As: Status

