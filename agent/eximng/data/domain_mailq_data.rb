module MCollective
  module Data
    class Domain_mailq_data<Base
      query do |domain|
        exiqgrep = Config.instance.pluginconf.fetch("exim.paths.exigrep", "/usr/sbin/exiqgrep")

        mailq = runcmd("#{exiqgrep} -r %s" % domain)
        mailq = parse_mailq_output(mailq)

        result[:size] = mailq.size
      end

      def runcmd(command)
        out = ""

        shell = Shell.new(command, :stdout => out)

        shell.runcommand

        raise("Command #{command} failed with status #{status} and error: #{err}") unless shell.status.exitstatus == 0

        return out.chomp
      end

      def parse_mailq_output(output)
        messages = []
        msg = nil

        output << "\n"

        output.each do |line|
          line.chomp!

          if line =~ /^\s*(.+?)\s+(.+?)\s+(.+-.+-.+) (<.*>)/
            msg = {}
            msg[:recipients] = Array.new
            msg[:frozen] = false

            msg[:age] = $1
            msg[:size] = $2
            msg[:msgid] = $3
            msg[:sender] = $4

            msg[:frozen] = true if line =~ /frozen/
          elsif line =~ /\s+(\S+?)@(.+)/ and msg
            msg[:recipients] << "#{$1}@#{$2}"
          elsif line =~ /^$/ && msg
            messages << msg
            msg = nil
          end
        end

        messages
      end
    end
  end
end



