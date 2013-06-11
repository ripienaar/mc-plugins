module MCollective
  class Discovery
    class Ec2
      require 'fog'

      class << self
        def discover(filter, timeout, limit=0, client=nil)
          config = Config.instance

          region = config.pluginconf.fetch("ec2.region", "eu-west-1")
          connection = Fog::Compute.new({:provider => 'AWS', :region => region})
          servers = simplify_servers(connection.servers)

          found = []

          filter.keys.each do |key|
            case key
              when "fact"
                fact_search(filter["fact"], servers, found)

              when "cf_class"
                class_search(filter["cf_class"], servers, found)

              when "identity"
                identity_search(filter["identity"], servers, found)
            end
          end

          # filters are combined so we get the intersection of values across
          # all matches found using fact, agent and identity filters
          found.inject(found[0]){|x, y| x & y}
        end

        def fact_search(filter, servers, found)
          return if filter.empty?

          matched = []

          filter.each do |f|
            fact = f[:fact]
            value = f[:value]
            operator = f[:operator]

            servers.each do |server|
              case operator
                when "=="
                  matched << server["private_dns_name"] if server[fact] == value
                when "=~"
                  matched << server["private_dns_name"] if server[fact] =~ regexy_string(value)
                when "!="
                  matched << server["private_dns_name"] unless server[fact] == value
                else
                  raise "Cannot perform '%s' matches for facts using the ec2 discovery method" % f[:operator]
              end
            end
          end

          found << matched
        end

        def class_search(filter, servers, found)
          return if filter.empty?

          matched = []

          filter.each do |f|
            servers.each do |server|
              [server["groups"]].flatten.each do |group|
                matched << server["private_dns_name"] if group.match(regexy_string(f))
              end
            end
          end

          found << matched.compact
        end

        def identity_search(filter, servers, found)
          return if filter.empty?

          matched = []

          filter.each do |f|
            servers.each do |server|
              matched << server["private_dns_name"] if server["private_dns_name"].match(regexy_string(f))
            end
          end

          found << matched.compact
        end

        def simplify_servers(servers)
          servers.select{|s| s.state == "running"}.map do |server|
            hsh = {}

            server.attributes.each do |attribute, value|
              hsh[attribute.to_s] = value
            end

            server.attributes[:tags].each do |tag, value|
              hsh["tag_%s" % tag] = value if value
            end

            hsh
          end
        end

        def regexy_string(string)
          if string.match("^/")
            Regexp.new(string.gsub("\/", ""))
          else
            string
          end
        end
      end
    end
  end
end
