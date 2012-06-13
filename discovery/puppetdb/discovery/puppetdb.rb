require 'net/http'
require 'net/https'

module MCollective
  class Discovery
    class Puppetdb
      def self.discover(filter, timeout, limit=0, client=nil)
        http = Net::HTTP.new('puppetdb.devco.net', 443)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE

        found = []

        filter.keys.each do |key|
          case key
            when "identity"
              identity_search(filter["identity"], http, found)

            when "cf_class"
              class_search(filter["cf_class"], http, found)

            when "fact"
              fact_search(filter["fact"], http, found)
          end
        end

        # filters are combined so we get the intersection of values across
        # all matches found using fact, agent and identity filters
        found = found.inject(found[0]){|x, y| x & y}

        found.flatten.map do |node|
          if node =~ /^(.+?)\.\w+\.net/
            $1
          else
            node
          end
        end
      end

      def self.fact_search(filter, http, found)
        return if filter.empty?

        selected_hosts = []

        filter.each do |fact|
          raise "Can only do == matches using the PuppetDB discovery" unless fact[:operator] == "=="

          query = ["and", ["=", ["fact", fact[:fact]], fact[:value]]]

          resp, data = http.get("/nodes?query=%s" % URI.escape(query.to_json), {"accept" => "application/json"})
          raise "Failed to retrieve nodes from PuppetDB: %s: %s" % [resp.code, resp.message] unless resp.code == "200"

          found << JSON.parse(data)
        end
      end

      def self.class_search(filter, http, found)
        return if filter.empty?

        selected_hosts = []

        filter.each do |klass|
          klass = klass.split("::").map{|i| i.capitalize}.join("::")
          raise "Can not do regular expression matches for classes using the PuppetDB discovery method" if regexy_string(klass).is_a?(Regexp)

          query = ["and", ["=", "type", "Class"], ["=", "title", klass]]

          resp, data = http.get("/resources?query=%s" % URI.escape(query.to_json), {"accept" => "application/json"})
          raise "Failed to retrieve nodes from PuppetDB: %s: %s" % [resp.code, resp.message] unless resp.code == "200"

          found << JSON.parse(data).map{|found| found["certname"]}
        end
      end

      def self.identity_search(filter, http, found)
        return if filter.empty?

        resp, data = http.get("/nodes", {"accept" => "application/json"})
        raise "Failed to retrieve nodes from PuppetDB: %s: %s" % [resp.code, resp.message] unless resp.code == "200"

        all_hosts = JSON.parse(data)
        selected_hosts = []

        filter.each do |identity|
          identity = regexy_string(identity)

          if identity.is_a?(Regexp)
            selected_hosts << all_hosts.grep(identity)
          else
            selected_hosts << identity if all_hosts.include?(identity)
          end
        end

        found << selected_hosts
      end

      def self.regexy_string(string)
        if string.match("^/")
          Regexp.new(string.gsub("\/", ""))
        else
          string
        end
      end
    end
  end
end
