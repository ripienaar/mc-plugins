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
        class Urltest
            attr_reader :timeout, :meta

            def initialize
                @timeout = 10
                @log = Log.instance
                @config = Config.instance

                @meta = {:license => "GPLv2",
                         :author => "R.I.Pienaar <rip@devco.net>",
                         :url => "http://code.google.com/p/mcollective-plugins/"}

            end
                
            def handlemsg(msg, connection)
                req = msg[:body]

                result = {}

                result["testurl"] = req["url"]

                begin
                    url = URI.parse(req["url"])
        
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
        
                        result["lookuptime"] = times["afterdns"] - times["beforedns"]
                        result["connectime"] = times["afteropen"] - times["beforeopen"]
                        result["prexfertime"] = times["firstline"] - times["afteropen"]
                        result["startxfer"] = times["firstline"] - times["afterrequest"]
                        result["bytesfetched"] = response.join.length
                        result["totaltime"] = times["end"] - times["beforedns"]

                        if @config.pluginconf.include?("urltest.syslocation")
                            result["testerlocation"] = @config.pluginconf["urltest.syslocation"]
                        else
                            result["testerlocation"] = "Please set plugin.urltest.syslocation"
                        end
                    else
                        raise("Unsupported url scheme: #{url.scheme}")
                    end
                rescue Exception => e
                    result["exception"] = e.to_s
                end

                result
            end

            def help
                <<-EOH
                URL Tester
                =============

                Performs a simple HTTP get against a web server and return stats about the request.

                Configuration
                -------------
               
                Set the plugin.urltest.syslocation option to a string that will be the location report
                for the node.

                Accepted Messages
                -----------------

                Input should be a hash of the form:

                {"url" => "http://digg.com"}

                The output will be a hash more or less like this:

                  {"testurl"=>"http://digg.com/",
                   "lookuptime"=>0.0011,
                   "prexfertime"=>0.322711,
                   "startxfer"=>0.322677,
                   "bytesfetched"=>89054,
                   "connectime"=>0.181278,
                   "testerlocation"=>"Your Network",
                   "totaltime"=>2.671358},

                EOH
            end
        end
    end
end

# vi:tabstop=4:expandtab:ai
