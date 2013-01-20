module MCollective
  class Application::Plot<MCollective::Application
    description "Plots data provided by Data Plugins"

    usage <<-END_OF_USAGE
mco plot [data plugin] [output item]
Usage: mco plot [data plugin] [data query] [output item]

Example:

With the Puppet agent installed, this will plot the total
config retrieval time for all nodes.

   mco plot resource config_retrieval_time

The nodes will by default be grouped into 20 buckets to provide
a scaling function, you can increase this to more buckets to
gain better data resolution:

   mco plot resource config_retrieval_time --buckets 60

For data plugins that require a data query you need to supply
that:

   mco plot fstat /etc/hosts size

This will plot the size of /etc/hosts across your estate

The various title, axis titles and overwall graph width and
height is also settable.
END_OF_USAGE

    option :x_title,
           :description => "Sets a title for the X axis",
           :arguments   => ["--xtitle [TITLE]"]

    option :y_title,
           :description => "Sets a title for the Y axis",
           :arguments   => ["--ytitle [TITLE]"]


    option :title,
           :description => "Sets the graph title",
           :arguments   => ["--title [TITLE]"]

    option :buckets,
           :description => "How many buckets to group nodes into",
           :arguments   => ["--buckets [COUNT]"],
           :default     => 20,
           :type        => Integer

    option :width,
           :description => "Set the graph width in characters",
           :arguments   => ["--width [WIDTH]"],
           :default     => 78,
           :type        => Integer

    option :height,
           :description => "Set the graph width in characters",
           :arguments   => ["--height [HEIGHT]"],
           :default     => 24,
           :type        => Integer

    def post_option_parser(configuration)
      raise "Please specify a data plugin, query and field to plot" unless ARGV.size >= 2

      if ARGV.size == 2
        configuration[:datasource] = ARGV.shift
        configuration[:field] = ARGV.shift
      elsif ARGV.size == 3
        configuration[:datasource] = ARGV.shift
        configuration[:query] = ARGV.shift
        configuration[:field] = ARGV.shift
      end
    end

    def validate_configuration(configuration)
      raise "Cannot find the 'gnuplot' executable" unless configuration[:gnuplot] = which("gnuplot")
    end

    def data_for_field(results, field)
      bucket_count = configuration[:buckets]

      buckets = Array.new(bucket_count + 1) { 0 }
      values = []

      results.each do |result|
        if result[:statuscode] == 0
          begin
            values << Float(result[:data][field])
          rescue => e
            raise "Cannot interpret data item '%s': %s" % [result[:data][field], e.to_s]
          end
        end
      end

      raise "No usable data results were found" if values.empty?

      min = values.min
      max = values.max

      bucket_size = (max - min) / Float(bucket_count)

      unless max == min
        values.each do |value|
          bucket = (value - min) / bucket_size
          buckets[bucket] += 1
        end
      end

      range = Array.new(bucket_count + 1) {|i| Integer(min + (i * bucket_size))}

      [range, buckets]
    end

    def which (bin)
      if Util.windows?
        all = [bin, bin + '.exe']
      else
        all = [bin]
      end

      all.each do |exec|
        if which_helper(exec)
          return which_helper(exec)
        end
      end

      return nil
    end

    def which_helper(bin)
      return bin if File::executable?(bin)

      ENV['PATH'].split(File::PATH_SEPARATOR).each do |dir|
        candidate = File::join(dir, bin.strip)
        return candidate if File::executable?(candidate)
      end
      return nil
    end

    def main
      client = rpcclient("rpcutil")

      args = {:source => configuration[:datasource]}
      args[:query] = configuration[:query] if configuration[:query]

      ddl = DDL.new("%s_data" % configuration[:datasource], :data)

      x, data = data_for_field(client.get_data(args), configuration[:field].to_sym)

      plot = StringIO.new

      plot.puts 'set title "%s"' % configuration.fetch(:title, ddl.meta[:description])
      plot.puts 'set terminal dumb %d %d' % [configuration[:width], configuration[:height]]
      plot.puts 'set key off'
      plot.puts 'set ylabel "%s"' % configuration.fetch(:y_title, "Nodes")
      plot.puts 'set xlabel "%s"' % configuration.fetch(:x_title, ddl.dataquery_interface[:output][configuration[:field].to_sym][:display_as])
      plot.puts "plot '-' with lines"

      x.each_with_index do |v, i|
        plot.puts "%s %s" % [v, data[i]]
      end

      output = ""

      begin
        IO::popen(configuration[:gnuplot], "w+") do |io|
          io.write plot.string
          io.close_write
          output = io.read
        end
      rescue => e
        raise "Could not plot results: %s" % e.to_s
      end

      puts output

      halt client.stats
    end
  end
end
