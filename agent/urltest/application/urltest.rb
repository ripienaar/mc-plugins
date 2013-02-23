# encoding: utf-8
module MCollective
  class Application::Urltest<MCollective::Application
    description "Test and gather connection stats for a specific URL"

    usage "mco urltest url"

    def post_option_parser(configuration)
      configuration[:url] = ARGV.shift
    end

    def validate_configuration(configuration)
      raise "Please specify a URL to test" unless configuration[:url]
    end

    def stats_for_field(results, field)
      good_results = results.select{|r| r[:statuscode] == 0}.map{|r| r[:data][field]}

      mean = good_results.inject(0) {|sum, x| sum += x } / good_results.size.to_f
      variance = good_results.inject(0) { |variance, x| variance += (x - mean) ** 2 }
      stddev = Math.sqrt(variance/(good_results.size-1))

      "min: %.4f max: %.4f avg: %.4f sdev: %.4f" % [good_results.min, good_results.max, mean, stddev]
    end

    def main
      tester = rpcclient("urltest", :options => options)

      results = tester.perftest(:url => configuration[:url])

      puts Util.colorize(:bold, "      Tester Location DNS      Connect    Pre-xfer   Start-xfer Total      Bytes Fetched")

      results.sort_by{|r| r[:data][:totaltime] rescue 0}.each do |result|
        res = result[:data]

        puts "%20s: %.4f   %.4f     %.4f     %.4f     %.4f     %d" % [ res[:testerlocation], res[:lookuptime], res[:connectime], res[:prexfertime], res[:startxfer], res[:totaltime], res[:bytesfetched]]
      end

      puts

      puts Util.colorize(:bold, "Summary:")
      puts

      puts "      DNS lookup time: %s" % stats_for_field(results, :lookuptime)
      puts "     TCP connect time: %s" % stats_for_field(results, :connectime)
      puts "   Time to first byte: %s" % stats_for_field(results, :prexfertime)
      puts "   HTTP Responce time: %s" % stats_for_field(results, :startxfer)
      puts "     Total time taken: %s" % stats_for_field(results, :totaltime)

      puts

      halt tester.stats
    end
  end
end
