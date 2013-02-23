require 'net/http'
require 'socket'

module MCollective
  module Agent
    class Urltest<RPC::Agent
      action "perftest" do
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
          reply.fail "Unsupported url scheme: %s" % url.scheme
        end
      end
    end
  end
end
