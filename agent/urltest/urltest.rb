require 'net/http'
require 'socket'
require 'ostruct'

module MCollective
    module Agent
        # An agent that performs a web get and report stats back to the client
        #
        # See http://code.google.com/p/mcollective-plugins/wiki/AgentUrltest
        #
        # Released under the terms of the GPLv2
        class Urltest<RPC::Agent
            attr_reader :timeout, :meta

            def startup_hook
                @meta = {:license => "Apache License 2",
                         :author => "R.I.Pienaar <rip@devco.net>",
                         :url => "http://code.google.com/p/mcollective-plugins/",
                         :version => "1.1"}

                @timeout = 10
            end
                
            def perftest_action
                validate :url, :shellsafe

                begin
                    url = URI.parse(request[:url])
        
                    times = {}
                            
                    if url.scheme == "http"
                        times["beforedns"] = Time.now
                        name = TCPSocket.gethostbyname(url.host)
                        times["afterdns"] = Time.now
        
                        times["beforeopen"] = Time.now
                        socket = TCPSocket.open(url.host, url.port)
                        times["afteropen"] = Time.now
        
                        socket.print("GET #{url.request_uri} HTTP/1.1\r\nHost: #{url.host}\r\nUser-Agent: Webtester\r\nAccept: */*\r\nConnection: close\r\n\r\n")
                        times["afterrequest"] = Time.now
        
                        response = Array.new
        
                        while line = socket.gets
                            times["firstline"] = Time.now unless times.include?("firstline")
        
                            response << line
                        end
        
                        socket.close
        
                        times["end"] = Time.now
        
                        reply[:lookuptime] = times["afterdns"] - times["beforedns"]
                        reply[:connectime] = times["afteropen"] - times["beforeopen"]
                        reply[:prexfertime] = times["firstline"] - times["afteropen"]
                        reply[:startxfer] = times["firstline"] - times["afterrequest"]
                        reply[:bytesfetched] = response.join.length
                        reply[:totaltime] = times["end"] - times["beforedns"]

                        if Config.instance.pluginconf.include?("urltest.syslocation")
                            reply[:testerlocation] = Config.instance.pluginconf["urltest.syslocation"]
                        else
                            reply[:testerlocation] = "Please set plugin.urltest.syslocation"
                        end
                    else
                        reply.fail "Unsupported url scheme: #{url.scheme}"
                        return
                    end
                rescue Exception => e
                    reply.fail e.to_s
                    return
                end
            end

            def help
                <<-EOH
                SimpleRPC URL Tester
                ====================

                This is a simple url tester that connects to a supplied url
                and return some simple metrics.

                ACTION:
                    perftest

                INPUT:
                    :url    The url to test, only http://... is supported

                OUTPUT:
                    A hash with various performance metrics
                EOH
            end
        end
    end
end

# vi:tabstop=4:expandtab:ai
