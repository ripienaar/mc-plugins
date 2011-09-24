What?
=====

A rework of my now ancient Exim agent for MCollective.  The old agent predated
SimpleRPC so it was a protocol on it's own, this new agent is fully SimpleRPC
based.

This version will handle bigger spools better - it will still be slow to fetch an
entire spool with 10s of thousands of mails on it but you now have the ability to
dig into the spool using the usual _exigrep_ features.  The filters are done server
side so should be much more efficient than before.

At present there isn't a new dialog interface like the old dialog interface but we
hope to recreate that feature based on this agent soon.  We've though created a capable
CLI application that makes using this agent quite easy.

Usage?
======

The included application plugin does most of what is needed in general use:

    % mco exim --help

    MCollective Exim Manager

    Usage: Usage: mco exim [mailq|size|summary|exiwhat|rmbounces|rmfrozen|runq]
    Usage: Usage: mco exim runq <pattern>
    Usage: Usage: mco exim [retry|markdelivered|freeze|thaw|giveup|rm] <message id>
    Usage: Usage: mco exim [addrecipient|markdelivered] <message id> <recipient>
    Usage: Usage: mco exim setsender <message id> <sender>
    Usage: Usage: mco exim <message matchers> [mailq|size]

      --match-sender, --limit-sender SENDER               Match sender pattern
      --match-recipient, --limit-recipient RECIPIENT      Match recipient pattern
      --match-younger, --limit-younger                    Match younger than seconds
      --match-older, --limit-older SECONDS                Match older than seconds
      --match-frozen, --limit-frozen                      Match only frozen messages
      --match-active, --limit-active                      Match only active messages

Retrieve the mail queue
-----------------------

The mail queue can be retrieved in whole or in part by using filters, the display will
match what the built in mailq application would show so you can pipe the network wide
mail queue into whatever existing scripts you have.

    $ mco exim mailq

    $ mco exim mailq --limit-frozen

    $ mco exim mailq --limit-sender foo.com

TODO: delivery status of individual recipients on a message with many recipients is not
handled, we simply don't return delivered addresses.

Mail queue sizes
----------------

You can get a quick summary of mail queue sizes for your entire network:

    $ mco exim size

       mx1.your.net:  total mail: 12     matched mail: 12     frozen mail: 0
       mx2.your.net:  total mail: 21     matched mail: 21     frozen mail: 16
       mx3.your.net:  total mail: 25     matched mail: 25     frozen mail: 3
       mx4.your.net:  total mail: 31     matched mail: 31     frozen mail: 18
                                  --                   --                  --
                                  89                   89                  37

As with the mail queue command you can use the standard matchers to limit:

    % mco exim size --limit-recipient foo.com

       mx1.your.net:  total mail: 12     matched mail: 1      frozen mail: 0
       mx2.your.net:  total mail: 21     matched mail: 14     frozen mail: 14
       mx3.your.net:  total mail: 25     matched mail: 0      frozen mail: 0
       mx4.your.net:  total mail: 31     matched mail: 15     frozen mail: 15
                                  --                   --                  --
                                  89                   30                  29

Here the total mail still represent all mail on the server but the matched and
frozen is limited to mail destined for foo.com

The mail queue summary is your standard _exiqsumm_ output but for the entire network,
as it's already a simple summary no matching is allowed:

    % mco exim summary
    Count  Volume  Oldest  Newest  Domain
    -----  ------  ------  ------  ------

        3    34KB     22h     18h  229-94.webeventstadium.com
        1    1843     17h     17h  alsg-italia.org
        1    2048     14h     14h  auditcomconsulting.cz
        .
        .
        .
    ---------------------------------------------------------------
      121  2419KB      9d     43m  TOTAL

Managing the mail queue and its contents
----------------------------------------

You can remove, edit, freeze and thaw messages on the queue.

Most of these actions are limited to single messages or the entire queue
we hope to add matchers to retry, freeze, thaw and rm so that these actions
can be taken on all messages matching recipient, sender etc.

Common uses:

Do a forced retry on a single message:

     % mco exim retry 1R6TJa-0000fA-5Z

       mx1.your.net: Message 1R6TJa-0000fA-5Z has been retried
       mx2.your.net: No message matching 1R6TJa-0000fA-5Z

Mark a message as delivered, the exim queue daemon will remove it later:

     % mco exim markdelivered 1R6TJa-0000fA-5Z

Mark a single recipient on a message as delivered:

     % mco exim markdelivered 1R6TJa-0000fA-5Z foo@example.com

Freeze and thaw a message:

     % mco exim freeze 1R6TJa-0000fA-5Z
     % mco exim thaw 1R6TJa-0000fA-5Z

Stop trying to deliver a message and create a non delivery report:

     % mco exim giveup 1R6TJa-0000fA-5Z

Removes a message without creating a non delivery report:

     % mco exim rm 1R6TJa-0000fA-5Z

Add a recipient to a message:

     % mco exim addrecipient 1R6TJa-0000fA-5Z foo@example.com

       mx1.your.net: foo@example.com has been added to message 1R6TJa-0000fA-5Z
       mx2.your.net: No message matching 1R6TJa-0000fA-5Z

Edit the sender of a message:

     % mco exim setsender 1R6TJa-0000fA-5Z foo@example.com

Remove all frozen mail from the queue:

     % mco exim rmfrozen

       mx1.your.net: 5 messages deleted
       mx2.your.net: 8 messages deleted
       mx3.your.net: 3 messages deleted

Remove all mail with postmaster as sender:

     % mco exim rmbounces

       mx1.your.net: 5 messages deleted
       mx2.your.net: 8 messages deleted
       mx3.your.net: 3 messages deleted

Do a normal background queue run:

     % mco exim runq

Do a queue run for messages matching example.com:

     % mco exim runq example.com

       mx1.your.net: Delivery for pattern example.com has been scheduled
       mx2.your.net: Delivery for pattern example.com has been scheduled
       mx3.your.net: Delivery for pattern example.com has been scheduled

Server Activity
---------------

You can figure out what all your servers are doing using exiwhat, this agent will run
exiwhat and so let you get a simple network wide view:

    % mco exim exiwhat

    mx1.your.net
         1865 daemon: -q1h, listening for SMTP on port 25 (IPv6 and IPv4)
        12285 handling incoming connection from (94.102.224.6) [94.102.224.6]
        12290 handling incoming connection from 93-86-76-68.dynamic.isp.telekom.rs (discus) [93.86.76.68]

    mx2.your.net
         2688 daemon: -q1h, listening for SMTP on port 25 (IPv6 and IPv4)
        15593 handling incoming connection from (outgoing-26.annoyoushypobenthos.info) [209.222.114.228]
        15655 handling incoming connection from (mqja.com) [88.250.93.236]

You can also do a network wide _exigrep_ to find all log lines relating some activity, you should
use this with caution as on busy servers the files can be huge and it can put considerable load
on your servers, just like when you use exigrep on the CLI.

    % mco exim exigrep foo.org.uk

    mx1.your.net
         Matches: +++ 1R7DXr-0006vV-Pa has not completed +++
                  2011-09-23 22:44:31 1R7DXr-0006vV-Pa <= <> R=1R5kqf-0006ro-TT U=exim P=local S=6323 T="Mail delivery failed: returning message to sender"
                  2011-09-24 07:41:17 1R7DXr-0006vV-Pa == foo.org.uk.606774.david@host117.enginereliable.com R=dnslookup T=remote_smtp defer (-18): Remote host host117.enginereliable.com [205.204.86.119] closed connection in response to end of data
                  2011-09-24 11:32:28 1R7DXr-0006vV-Pa == foo.org.uk.606774.david@host117.enginereliable.com R=dnslookup T=remote_smtp defer (-53): retry time not reached for any host

