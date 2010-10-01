# Simple agent to ping locations from mcollective hosts
# Useful if you have a network of servers around the world and want
# to test connectivity to ensure faults aren't just local
#
# GPL v2 License
#
#
# Usage: mc-rpc ping ping fqdn="<hostname>"
# Example: mc-rpc ping ping fqdn="google.com"


require 'rubygems'
require 'net/ping'

module MCollective
    module Agent
        class Ping<RPC::Agent


            metadata    :name        => "Ping",
                        :description => "Agent to ping from a location",
                        :author      => "Dean Smith",
                        :license     => "BSD",
                        :version     => "1.0",
                        :url         => "http://github.com/deasmi",
                        :timeout     => 60

            action "ping" do 
		          validate :fqdn,String

		          fqdn = request[:fqdn]

		          icmp = Net::Ping::ICMP.new(fqdn)

		          if icmp.ping? then 
			          reply[:rtt] = (icmp.duration*1000).to_s
			          reply[:fqdn] = fqdn
                reply[:time] = Time.now.to_s
		          else 
			          reply.fail "Could not ping host "
		          end
            end
        end
    end
end
  