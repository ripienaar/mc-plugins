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
            def req(command, recipient="", sender="", msgid="", queuematch="")
                req  = {:command => command,
                        :recipient => recipient,
                        :sender => sender,
                        :msgid => msgid,
                        :queuematch => queuematch}

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

            # Retries delivery for a specified message 
            def retrymsg(msgid)
                req("retrymsg", "", "", msgid, "")
            end

            # Adds a recipient to a given message
            def addrecipient(msgid, recipient)
                req("addrecipient", recipient, "", msgid, "")
            end

            # Sets the sender for a messageid
            def setsender(msgid, sender)
                req("setsender", "", sender, msgid, "")
            end

            # Mark an entire message as delivered
            def markmsgdelivered(msgid)
                req("markmsgdelivered", "", "", msgid, "")
            end

            # Marks a single recipient on a message as delivered
            def markrecipdelivered(msgid, recipient)
                req("markrecipdelivered", recipient, "", msgid, "")
            end

            # Freeze a message
            def freeze(msgid)
                req("freeze", "", "", msgid, "")
            end

            # Unfreeze a message
            def thaw(msgid)
                req("thaw", "", "", msgid, "")
            end

            # Gives up on a message with NDR
            def giveup(msgid)
                req("giveup", "", "", msgid, "")
            end

            # Removes a specified message from the queue
            def rm(msgid)
                req("rm", "", "", msgid, "")
            end

            # Delivers all messages matching a patten
            def delivermatching(pattern)
                req("delivermatching", "", "", "", pattern)
            end

            # Does a routing test
            def testaddress(address)
                req("testaddress", address, "", "", "")
            end

            # Catchall for the rest, they're mostly the same but this gives us the ability
            # to only improve when needed
            def method_missing(method_name, *args)
                req(method_name.to_s)
            end
        end
    end
end

# vi:tabstop=4:expandtab:ai:filetype=ruby
