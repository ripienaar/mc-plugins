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

            # helper to print out responses from hosts in a consistant way
            def printhostresp(resp)
                if resp[:body].is_a?(String)
                    puts("#{resp[:senderid]}:")
                    puts "     " + resp[:body].split("\n").join("\n     ")
                    puts
                elsif resp[:body].is_a?(Array)
                    puts("#{resp[:senderid]}:")
                    puts "     " + resp[:body].join("\n     ")
                    puts
                else
                    puts("#{resp[:senderid]} responded with a #{resp[:body].class}")
                end
            end

            # helper to print the mailq in a way similar to the exim mailq command
            def printmailq(mailq)
                mailq.each do |m|
                    m[:frozen] ? frozen = "*** frozen ***" : frozen = ""
                
                    printf("%3s%6s %s %s %s\n", m[:age], m[:size], m[:msgid], m[:sender], frozen)
                
                    m[:recipients].each do |r|
                        puts("          #{r}")
                    end
                
                    puts
                end
            end

            # Creates a request that confirms with what the remote end expects.  Sends the 
            # request off to the collective and either runs your block with the response 
            # or returns it.
            def req(command)
                req  = {:command => command,
                        :recipient => @options[:recipient],
                        :sender => @options[:sender],
                        :msgid => @options[:msgid],
                        :queuematch => @options[:queuematch]}

                @client.req(req, "exim", @options, discover.size) do |resp|
                    if block_given?
                        yield(resp)
                    else
                        return resp
                    end
                end
            end

            # Retrieves the mailq and returns the array of data
            def mailq
                mailq = []

                req("mailq") do |resp|
                    mailq.concat [resp[:body]].flatten
                end

                mailq
            end

            # Catchall for the rest, they're mostly the same but this gives us the ability
            # to only improve when needed
            def method_missing(method_name, *args)
                Log.instance.debug("method_missing doing request for #{method_name}")
                req(method_name.to_s)
            end
        end
    end
end

# vi:tabstop=4:expandtab:ai:filetype=ruby
