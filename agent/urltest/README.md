What?
=====

A simple MCollective agent to do a banchmark of a specied URL.

Usage?
------

<pre>
% mco urltest http://www.devco.net/

 * [ ============================================================> ] 11 / 11

      Tester Location DNS      Connect    Pre-xfer   Start-xfer Total      Bytes Fetched
               node3: 5.0086   0.0066     0.7277     0.7272     6.9230     101859
               node8: 5.0127   0.0054     0.8764     0.8761     7.1109     101859
          middleware: 5.0063   0.0044     0.8985     0.8982     7.1212     101859
               node7: 5.0097   0.0082     0.9753     0.9749     7.1797     101859
               node4: 5.0070   0.0069     0.8708     0.8702     7.2758     101859
               node1: 5.0083   0.0077     1.0395     1.0386     7.2877     101859
               node9: 5.0127   0.0061     1.1421     1.1419     7.3066     101859
               node5: 5.0041   0.0052     0.9964     0.9959     7.3191     101859
               node0: 5.0433   0.0051     0.9715     0.9712     7.3205     101859
               node6: 5.0084   0.0050     0.9896     0.9892     7.3213     101859
               node2: 5.0126   0.0063     0.9806     0.9799     7.3277     101859

Summary:

      DNS lookup time: min: 5.0041 max: 5.0433 avg: 5.0122 sdev: 0.0107
     TCP connect time: min: 0.0044 max: 0.0082 avg: 0.0061 sdev: 0.0012
   Time to first byte: min: 0.7277 max: 1.1421 avg: 0.9517 sdev: 0.1070
   HTTP Responce time: min: 0.7272 max: 1.1419 avg: 0.9512 sdev: 0.1070
     Total time taken: min: 6.9230 max: 7.3277 avg: 7.2267 sdev: 0.1296
</pre>

Contact?
--------

R.I.Pienaar / rip@devco.net / @ripienaar / http://devco.net/
