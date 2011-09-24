module MCollective
    module Util
        # a helper class for the application plugin and cli only, this would
        # probably be very awkward to use for anything past that as its designed
        # to assist those 2 apps only, everyting returns text for display to the
        # user no data etc.
        #
        # To get access to the RPC supplied data, use the RPC api direct.
        class EximNG
            attr_reader :mc

            def initialize(mc)
                @mc = mc
            end

            # rm(:message_id => "xyz")
            def rm(args)
                requires(args, :message_id)

                std_msgid_action(:rm, args[:message_id])
            end

            # giveup(:message_id => "xyz")
            def giveup(args)
                requires(args, :message_id)

                std_msgid_action(:giveup, args[:message_id])
            end

            # thaw(:message_id => "xyz")
            def thaw(args)
                requires(args, :message_id)

                std_msgid_action(:thaw, args[:message_id])
            end

            # freeze(:message_id => "xyz")
            def freeze(args)
                requires(args, :message_id)

                mc.instance_eval { undef :freeze }

                std_msgid_action(:freeze, args[:message_id])
            end

            # markdelivered(:message_id => "xyz")
            # markdelivered(:message_id => "xyz", :recipient => "foo@foo.com")
            def markdelivered(args)
                requires(args, :message_id)

                if args.include?(:recipient)
                    std_recipient_action(:markdelivered, args[:message_id], args[:recipient])
                else
                    std_msgid_action(:markdelivered, args[:message_id])
                end
            end

            # retry(:message_id => "xyz")
            def retry(args)
                requires(args, :message_id)

                std_msgid_action(:retrymsg, args[:message_id])
            end

            # addrecipient(:message_id => "xyz", :recipient => "foo@foo.com")
            def addrecipient(args)
                requires(args, :message_id)
                requires(args, :recipient)

                std_recipient_action(:addrecipient, args[:message_id], args[:recipient])
            end

            # setsender(:message_id => "xyz", :sender => "foo@foo.com")
            def setsender(args)
                requires(args, :message_id)
                requires(args, :sender)

                result = StringIO.new

                mc.setsender(:msgid => args[:message_id], :sender => args[:sender]).each do |r|
                    if r[:statuscode] == 0
                        msg = r[:data][:status]
                    else
                        msg = r[:statusmsg]
                    end

                    result.puts "%30s: %s" % [r[:sender], msg]
                end

                result.string
            end

            # runq()
            # runq(:pattern => "foo.com")
            def runq(args={})
                result = StringIO.new

                if args.include?(:pattern)
                    mcresult = mc.delivermatching(:pattern => args[:pattern])
                else
                    mcresult = mc.runq
                end

                mcresult.each do |r|
                    if r[:statuscode] == 0
                        msg = r[:data][:status]
                    else
                        msg = r[:statusmsg]
                    end

                    result.puts "%30s: %s" % [r[:sender], msg]
                end

                return result.string
            end

            # exigrep(:pattern => "foo")
            def exigrep(args)
                requires(args, :pattern)

                MCollective::RPC::Helpers.rpcresults(mc.exigrep(:pattern => args[:pattern]), {:format => :console})
            end

            # test(:recipient => "foo@foo.com")
            def test(args)
                requires(args, :address)

                MCollective::RPC::Helpers.rpcresults(mc.testaddress(:address => args[:address]), {:format => :console})
            end

            def rmfrozen(args={})
                result = StringIO.new

                mc.rmfrozen.each do |r|
                    if r[:statuscode] == 0
                        msg = r[:data][:status]
                    else
                        msg = "No frozen messages found"
                    end

                    result.puts "%30s: %s" % [r[:sender], msg]
                end

                return result.string
            end

            def rmbounces(args={})
                result = StringIO.new

                mc.rmbounces.each do |r|
                    if r[:statuscode] == 0
                        msg = r[:data][:status]
                    else
                        msg = "No bounce messages found"
                    end

                    result.puts "%30s: %s" % [r[:sender], msg]
                end

                return result.string
            end

            def exiwhat(args={})
                failed = []
                result = StringIO.new

                mc.exiwhat.each do |r|
                    begin
                        result.puts r[:sender]
                        r[:data][:exiwhat].each do |line|
                            result.puts "\t#{line}"
                        end
                    rescue
                        failed << r
                    end

                    result.puts
                end

                result.print failed_report(failed)

                return result.string
            end

            # size(:limit_sender => "foo@foo.com")
            # size(:limit_recipient => "foo@foo.com")
            # size(:limit_younger_than => 120)
            # size(:limit_older_than => 120)
            # size(:limit_frozen_only => true)
            # size(:limit_unfrozen_only => true)
            def size(args={})
                result = StringIO.new

                stats = {:failed => [], :hosts => {}}

                mc.size(args).each do |s|
                    if s[:statuscode] == 0
                        stats[:hosts][ s[:sender] ] = {:total => s[:data][:total], :matched => s[:data][:matched], :frozen => s[:data][:frozen]}
                    else
                        stats[:failed] << s
                    end
                end

                hosts = stats[:hosts]
                total = 0; frozen = 0; matched = 0

                hosts.sort_by{|host| host[1][:total].to_i}.each do |host|
                    result.puts "%30s:  total mail: %-5d  matched mail: %-5d  frozen mail: %-5d" % [host[0], host[1][:total], host[1][:matched], host[1][:frozen]]

                    total += host[1][:total].to_i
                    matched += host[1][:matched].to_i
                    frozen += host[1][:frozen].to_i
                end

                result.puts "%45s%-5s%16s%-5s%15s%-5s" % [" ", "-" * total.to_s.size, " ", "-" * matched.to_s.size, " ", "-" * frozen.to_s.size]
                result.puts "%45s%-5d%16s%-5d%15s%-5d" % [" ", total, " ", matched, " ", frozen]

                result.print failed_report(stats[:failed])

                return result.string
            end

            # mailq(:limit_sender => "foo@foo.com")
            # mailq(:limit_recipient => "foo@foo.com")
            # mailq(:limit_younger_than => 120)
            # mailq(:limit_older_than => 120)
            # mailq(:limit_frozen_only => true)
            # mailq(:limit_unfrozen_only => true)
            def mailq(args={})
                failed = []
                result = StringIO.new

                mc.progress = false

                mc.mailq(args) do |r, s|
                    begin
                        s[:data][:mailq].each do |message|
                            result.puts exim_like_mailq(message)
                        end
                    rescue
                        failed << s
                    end
                end

                result.print failed_report(failed)

                return result.string
            end

            # summary(:limit_sender => "foo@foo.com")
            # summary(:limit_recipient => "foo@foo.com")
            # summary(:limit_younger_than => 120)
            # summary(:limit_older_than => 120)
            # summary(:limit_frozen_only => true)
            # summary(:limit_unfrozen_only => true)
            def summary(args={})
                failed = []
                result = StringIO.new
                text = ""

                mc.progress = false

                mc.mailq(args) do |r, s|
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
                    result.puts qsumm.read
                end

                result.print failed_report(failed)

                return result.string
            end

            private
            # does the hard work for any action that takes just an id and returns a :status
            def std_msgid_action(action, msgid)
                result = StringIO.new

                mc.send(action, :msgid => msgid).each do |r|
                    if r[:statuscode] == 0
                        msg = r[:data][:status]
                    else
                        msg = r[:statusmsg]
                    end

                    result.puts "%30s: %s" % [r[:sender], msg]
                end

                return result.string
            end

            def std_recipient_action(action, msgid, recipient)
                result = StringIO.new

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

                    result.puts "%30s: %s" % [r[:sender], msg]
                end

                return result.string
            end

            # Takes a message structure as returned by mailq and turns it into exim like text
            def exim_like_mailq(message)
                result = StringIO.new

                message[:frozen] ? frozen = "*** frozen ***" : frozen = ""

                result.puts "%3s%6s %s %s %s" % [ message[:age], message[:size], message[:msgid], message[:sender], frozen ]

                message[:recipients].each do |recipient|
                    result.puts "          #{recipient}"
                end

                result.puts

                return result.string
            end

            def failed_report(failed)
                result = StringIO.new

                unless failed.empty?
                    result.puts
                    result.puts "Failed to get data from some hosts:"

                    failed.each do |host|
                        result.puts "%30s: %s" % [ host[:sender], host[:statusmsg] ]
                    end
                end

                return result.string
            end

            def requires(haystack, needle)
                raise("#{needle} is required") unless haystack.include?(needle)
            end
        end
    end
end
