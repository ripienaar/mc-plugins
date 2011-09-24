class MCollective::Application::Exim<MCollective::Application
    description "MCollective Exim Manager"
    usage "Usage: mco exim [mailq|size|summary|exiwhat|rmbounces|rmfrozen|runq]"
    usage "Usage: mco exim runq <pattern>"
    usage "Usage: mco exim [retry|markdelivered|freeze|thaw|giveup|rm] <message id>"
    usage "Usage: mco exim [addrecipient|markdelivered] <message id> <recipient>"
    usage "Usage: mco exim setsender <message id> <sender>"
    usage "Usage: mco exim <message matchers> [mailq|size]"
    usage "Usage: mco exim exigrep pattern"

    VALID_COMMANDS = ["mailq", "size", "summary", "exiwhat", "rmbounces", "rmfrozen", "runq", "addrecipient", "markdelivered", "setsender", "retry", "markdelivered", "freeze", "thaw", "giveup", "rm", "delivermatching", "exigrep"]
    MSGID_REQ_COMMANDS = ["setsender", "retry", "markdelivered", "freeze", "thaw", "giveup", "rm"]
    RECIP_OPT_COMMANDS = ["markdelivered"]
    RECIP_REQ_COMMANDS = ["addrecipient"]

    option :limit_sender,
        :description    => "Match sender pattern",
        :arguments      => ["--match-sender SENDER", "--limit-sender"],
        :required       => false

    option :limit_recipient,
        :description    => "Match recipient pattern",
        :arguments      => ["--match-recipient RECIPIENT", "--limit-recipient"],
        :required       => false

    option :limit_younger_than,
        :description    => "Match younger than seconds",
        :arguments      => ["--match-younger SECONDS", "--limit-younger"],
        :required       => false

    option :limit_older_than,
        :description    => "Match older than seconds",
        :arguments      => ["--match-older SECONDS", "--limit-older"],
        :required       => false

    option :limit_frozen_only,
        :description    => "Match only frozen messages",
        :arguments      => ["--match-frozen", "--limit-frozen"],
        :type           => :bool,
        :required       => false

    option :limit_unfrozen_only,
        :description    => "Match only active messages",
        :arguments      => ["--match-active", "--limit-active"],
        :type           => :bool,
        :required       => false

    def post_option_parser(configuration)
        configuration[:command] = ARGV.shift if ARGV.size > 0

        if MSGID_REQ_COMMANDS.include?(configuration[:command])
            if ARGV.size > 0
                configuration[:message_id] = ARGV[0]
            else
                raise "#{configuration[:command]} requires a message id"
            end
        end

        if RECIP_REQ_COMMANDS.include?(configuration[:command])
            if ARGV.size == 2
                configuration[:message_id] = ARGV[0]
                configuration[:recipient] = ARGV[1]
            else
                raise "#{configuration[:command]} requires a message id and recipient"
            end
        end

        if RECIP_OPT_COMMANDS.include?(configuration[:command])
            if ARGV.size == 2
                configuration[:recipient] = ARGV[1]
            end
        end
    end

    def validate_configuration(configuration)
        raise "Please specify a command, see --help for details" unless configuration[:command]

        raise "Unknown command #{configuration[:command]}, see --help for full help" unless VALID_COMMANDS.include?(configuration[:command])

        if configuration.include?(:message_id)
            raise "Invalid message id format for id #{configuration[:message_id]}" unless configuration[:message_id] =~ /^\w+-\w+-\w+$/
        end
    end

    # does the hard work for any action that takes just an id and returns a :status
    def std_msgid_action(mc, action, msgid)
        mc.send(action, :msgid => msgid).each do |r|
            if r[:statuscode] == 0
                msg = r[:data][:status]
            else
                msg = r[:statusmsg]
            end

            puts "%30s: %s" % [r[:sender], msg]
        end
    end

    def std_recipient_action(mc, action, msgid, recipient)
        if recipient
            results = mc.send(action, :msgid => msgid, :recipient => recipient)
        else
            results = mc.send(action, :msgid => msgid)
        end

        results.each do |r|
            if r[:statuscode] == 0
                msg = r[:data][:status]
            else
                msg = r[:statusmsg]
            end

            puts "%30s: %s" % [r[:sender], msg]
        end
    end
    # Takes a message structure as returned by mailq and turns it into exim like text
    def exim_like_mailq(message)
        result = ""

        message[:frozen] ? frozen = "*** frozen ***" : frozen = ""

        result = "%3s%6s %s %s %s\n" % [ message[:age], message[:size], message[:msgid], message[:sender], frozen ]

        message[:recipients].each do |recipient|
            result << "          #{recipient}\n"
        end

        "#{result}\n"
    end

    def failed_report(failed)
        unless failed.empty?
            STDERR.puts
            STDERR.puts "Failed to get data from some hosts:"

            failed.each do |host|
                STDERR.puts "%30s: %s" % [ host[:sender], host[:statusmsg] ]
            end
        end
    end

    def mailq_command(mc)
        failed = []

        mc.progress = false

        mc.mailq(configuration) do |r, s|
            begin
                s[:data][:mailq].each do |message|
                    puts exim_like_mailq(message)
                end
            rescue
                failed << s
            end
        end

        failed_report(failed)
    end

    def summary_command(mc)
        failed = []
        text = ""

        mc.progress = false

        mc.mailq(configuration) do |r, s|
            begin
                s[:data][:mailq].each do |message|
                    text += exim_like_mailq(message)
                end
            rescue
                failed << s
            end
        end

        IO.popen("exiqsumm", "r+") do |qsumm|
            qsumm.puts text
            qsumm.close_write
            puts qsumm.read
        end

        failed_report(failed)
    end

    def size_command(mc)
        stats = {:failed => [], :hosts => {}}

        mc.size(configuration).each do |s|
            if s[:statuscode] == 0
                stats[:hosts][ s[:sender] ] = {:total => s[:data][:total], :matched => s[:data][:matched], :frozen => s[:data][:frozen]}
            else
                stats[:failed] << s
            end
        end

        hosts = stats[:hosts]
        total = 0; frozen = 0; matched = 0

        hosts.sort_by{|host| host[1][:total].to_i}.each do |host|
            puts "%30s:  total mail: %-5d  matched mail: %-5d  frozen mail: %-5d" % [host[0], host[1][:total], host[1][:matched], host[1][:frozen]]

            total += host[1][:total].to_i
            matched += host[1][:matched].to_i
            frozen += host[1][:frozen].to_i
        end

        puts "%45s%-5s%16s%-5s%15s%-5s" % [" ", "-" * total.to_s.size, " ", "-" * matched.to_s.size, " ", "-" * frozen.to_s.size]
        puts "%45s%-5d%16s%-5d%15s%-5d" % [" ", total, " ", matched, " ", frozen]

        failed_report(stats[:failed])
    end

    def exiwhat_command(mc)
        failed = []

        mc.exiwhat.each do |r|
            begin
                puts r[:sender]
                r[:data][:exiwhat].each do |line|
                    puts "\t#{line}"
                end
            rescue
                failed << r
            end

            puts
        end

        failed_report(failed)
    end

    def rmbounces_command(mc)
        mc.rmbounces.each do |r|
            if r[:statuscode] == 0
                msg = r[:data][:status]
            else
                msg = "No bounce messages found"
            end

            puts "%30s: %s" % [r[:sender], msg]
        end
    end

    def rmfrozen_command(mc)
        mc.rmfrozen.each do |r|
            if r[:statuscode] == 0
                msg = r[:data][:status]
            else
                msg = "No frozen messages found"
            end

            puts "%30s: %s" % [r[:sender], msg]
        end
    end

    def exigrep_command(mc)
        if ARGV.empty?
            raise("The exigrep command requires a pattern")
        else
            pattern = ARGV.first
        end

        printrpc mc.exigrep(:pattern => pattern)
    end

    def runq_command(mc)
        if ARGV.empty?
            result = mc.runq
        else
            pattern = ARGV.first
            result = mc.delivermatching(:pattern => pattern)
        end

        result.each do |r|
            if r[:statuscode] == 0
                msg = r[:data][:status]
            else
                msg = r[:statusmsg]
            end

            puts "%30s: %s" % [r[:sender], msg]
        end
    end

    def setsender_command(mc)
        if ARGV.size == 2
            sender = ARGV[1]
        else
            raise "Please supply a sender"
        end

        mc.setsender(:msgid => configuration[:message_id], :sender => sender).each do |r|
            if r[:statuscode] == 0
                msg = r[:data][:status]
            else
                msg = r[:statusmsg]
            end

            puts "%30s: %s" % [r[:sender], msg]
        end
    end

    def retry_command(mc)
        std_msgid_action(mc, :retrymsg, configuration[:message_id])
    end

    def markdelivered_command(mc)
        std_msgid_action(mc, :markdelivered, configuration[:message_id])
    end

    def freeze_command(mc)
        mc.instance_eval { undef :freeze }

        std_msgid_action(mc, :freeze, configuration[:message_id])
    end

    def thaw_command(mc)
        std_msgid_action(mc, :thaw, configuration[:message_id])
    end

    def giveup_command(mc)
        std_msgid_action(mc, :giveup, configuration[:message_id])
    end

    def rm_command(mc)
        std_msgid_action(mc, :rm, configuration[:message_id])
    end

    def addrecipient_command(mc)
        std_recipient_action(mc, :addrecipient, configuration[:message_id], configuration[:recipient])
    end

    def markdelivered_command(mc)
        std_recipient_action(mc, :markdelivered, configuration[:message_id], configuration[:recipient])
    end

    def main
        mc = rpcclient("eximng", :options => options)

        cmd = "#{configuration[:command]}_command"

        if respond_to?(cmd)
            send(cmd, mc)
        else
            raise "Support for #{configuration[:command]} has not yet been implimented"
        end

        mc.disconnect
    end
end
