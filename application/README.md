GNU Plotter for MCollective Data
================================

A small tool to plot data that can be gathered via MCollective data plugins.

Example
-------

If you have the Puppet agent install on your infrastructure you can use this
application to examine the behavior of your Puppet infrastructure.

    $ mco plot resource config_retrieval_time --np

                        Information about Puppet managed resources
      Nodes
          4 ++------*--------+-------+--------+-------+-------+--------+------++
            +       *        +       +        +       +       +        +       +
        3.5 ++     * *                                                        ++
            |      * *                                                         |
          3 ++     *  *           *                                           ++
            |     *   *          * *                                           |
            |     *    *        *  *                                           |
        2.5 ++    *    *        *   *                                         ++
            |    *      *      *    *                                          |
          2 ++   *      **    *      *                       ****             ++
            |             *   *       *                      *   *             |
        1.5 ++             *  *       *                      *   *            ++
            |               **         *                    *     *            |
          1 ++               *         *********            *     *     *     ++
            |                                   *           *      *   *       |
            |                                    *          *      *   *       |
        0.5 ++                                   *         *        * *       ++
            +       +        +       +        +   *   +    *  +     * *+       +
          0 ++------+--------+-------+--------+----*********--+------*-+------++
            0       5        10      15       20      25      30       35      40
                                   Config Retrieval Time

This shows you that the time to retrieve the configuration from my master is
generally fast but there are some slowdown of nodes taking > 25 seconds.

We can interogate the network and ask it which machines this is:

    $ mco find -S "resource().config_retrieval_time > 25"
    dev2.example.net
    .
    .
    .

This shows how you can first view and then dig into the graph and find nodes
matching it.

To see what data you can plot use the *mco plugin doc* application:

    $ mco plugin doc
    .
    .
    Data Queries:
      agent                     Meta data about installed MColletive Agents
      augeas_match              Allows agents and discovery to do Augeas match lookups
      domain_mailq              Checks the mailq for mail to a certain domain
      fstat                     Retrieve file stat data for a given file
      nrpe                      Checks the exit codes of executed Nrpe commands
      puppet                    Information about Puppet agent state
      resource                  Information about Puppet managed resources
      sysctl                    Retrieve values for a given sysctl

Any numeric data in these data sources can be plotted, see *mco plugin doc
data/puppet* to get details about a specific plugin.
