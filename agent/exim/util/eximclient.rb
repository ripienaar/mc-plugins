module MCollective
    module Util
        class EximClient
            attr_reader :discovered_clients

            def initialize(client)
                @discovered_clients = nil
                @client = client
                @options = client.options
            end

            # does a discovery and store the discovered clients so we do not need to do 
            # a discovery for every command we wish to run
            def discover
                if @discovered_clients == nil
                    @discovered_clients = @client.discover(@options[:filter], @options[:disctimeout])
                end

                @discovered_clients
            end

            # Resets the client so it will rediscover etc
            def reset
                @discovered_clients = nil
            end

            # Retrieves the mailq and returns the array of data
            def mailq
                mailq = []

                req  = {:command => "mailq",
                        :recipient => @options[:recipient],
                        :sender => @options[:sender],
                        :msgid => @options[:msgid],
                        :queuematch => @options[:queuematch]}

                @client.req(req, "exim", @options, discover.size) do |resp|
                    mailq.concat [resp[:body]].flatten
                end

                mailq
            end
        end
    end
end

# vi:tabstop=4:expandtab:ai:filetype=ruby
