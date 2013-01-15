module MCollective
  module Registration
    # A registration plugin that sends in all the metadata we have for a node
    # to redis, this will only work with the Redis connector and no other
    # connector
    #
    # Metadata being sent:
    #
    # - all facts
    # - all agents
    # - all classes (if applicable)
    # - the configured identity
    # - the list of collectives the nodes belong to
    # - last seen time
    #
    # Keys will be set to expire (2 * registration interval) + 2
    class Redis_registration<Base
      def body
        data = {:agentlist => [],
                :facts => {},
                :classes => [],
                :collectives => []}

        identity = Config.instance.identity

        cfile = Config.instance.classesfile

        if File.exist?(cfile)
          data[:classes] = File.readlines(cfile).map {|i| i.chomp}
        end

        data[:identity] = Config.instance.identity
        data[:agentlist] = Agents.agentlist
        data[:facts] = PluginManager["facts_plugin"].get_facts
        data[:collectives] = Config.instance.collectives.sort

        commit = lambda do |redis|
          begin
            redis.multi do
              prefix = "mcollective::%s::" % data[:identity]
              agents = [prefix, "agents"].join
              facts = [prefix, "facts"].join
              classes = [prefix, "classes"].join
              collectives = [prefix, "collectives"].join
              lastseen = [prefix, "lastseen"].join
              expiry = (Config.instance.registerinterval * 2) + 5

              redis.del agents, facts, classes, collectives, lastseen
              redis.rpush agents, data[:agentlist]
              redis.rpush classes, data[:classes]
              redis.rpush collectives, data[:collectives]
              redis.hmset facts, data[:facts].to_a.flatten
              redis.set lastseen, Time.now.to_i

              [prefix, agents, facts, classes, collectives, lastseen].each do |k|
                redis.expire k, expiry
              end
            end
          rescue => e
            Log.error("%s: %s: %s" % [e.backtrace.first, e.class, e.to_s])
          end
        end

        PluginManager["connector_plugin"].sender_queue << {:command => :proc, :proc => commit}
        nil
      end
    end
  end
end
