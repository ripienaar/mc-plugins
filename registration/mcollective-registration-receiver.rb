#!/usr/bin/env ruby

require 'mcollective'

module MCollective
    class Util::RegistrationDaemon
        def initialize
            oparser = Optionparser.new
            options = oparser.parse

            @config = Config.instance
            @config.loadconfig(options[:config])

            @connector = PluginManager["connector_plugin"]
            @connector.connect

            queue = Config.instance.pluginconf["registration_daemon_queue"] || "/queue/mcollective.registration"
            Log.info("Subscribing to #{queue} for new events")

            @connector.connection.subscribe(queue)

            Util.loadclass("MCollective::Agent::Registration")

            @agent = Agent::Registration.new

            Log.info("MCollective Registration daemon started")
        end

        def daemonize
            fork do
                Process.setsid
                exit if fork
                Dir.chdir('/tmp')
                STDIN.reopen('/dev/null')
                STDOUT.reopen('/dev/null', 'a')
                STDERR.reopen('/dev/null', 'a')

                yield
            end
        end

        def run
            if Config.instance.daemonize
                daeminize { receive_loop }
            else
                receive_loop
            end
        end

        def receive_loop
            loop do
                begin
                    msg = @connector.connection.receive

                    start_time = Time.now

                    registration_data = JSON.load(msg.body)

                    raise RPCAborted, "Did not receive a FQDN fact" unless registration_data["facts"].include?("fqdn")

                    sender = registration_data["facts"]["fqdn"]
                    registration_msg = {:senderid => sender, :body => registration_data}

                    begin
                        @agent.handlemsg(registration_msg, @connector)
                    rescue Exception => e
                        raise RPCAborted, "registration raised an unexpected exception: #{e.class}: #{e}"
                    end

                    Log.info("Processed registration data from %s in %.2f seconds" % [sender, (Time.now - start_time).to_f])

                rescue RPCAborted
                    Log.warn("Failed to handle registration data: #{e}")
                rescue Interrupt
                    Log.info("Exiting on interrupt signal")
                    exit
                rescue Exception => e
                    Log.error("Unexpected Exception: #{e.class}: #{e}")
                    sleep 1
                end
            end
        end
    end
end

receiver = MCollective::Util::RegistrationDaemon.new

receiver.run
