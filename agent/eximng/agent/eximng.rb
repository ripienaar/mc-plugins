module MCollective
    module Agent
        class Eximng<RPC::Agent
            def startup_hook
                @exim = config.pluginconf["exim.paths.exim"] || "/usr/sbin/exim"
                @mailq = config.pluginconf["exim.paths.mailq"] || "/usr/bin/mailq"
                @exiqsumm = config.pluginconf["exim.paths.exiqsumm"] || "/usr/sbin/exiqsumm"
                @exiwhat = config.pluginconf["exim.paths.exiwhat"] || "/usr/sbin/exiwhat"
                @exiqgrep = config.pluginconf["exim.paths.exigrep"] || "/usr/sbin/exiqgrep"
                @xargs = config.pluginconf["exim.paths.xargs"] || "/usr/bin/xargs"
                @spool = config.pluginconf["exim.paths.spool"] || "/var/spool/exim/input"
                @exigrep = config.pluginconf["exim.paths.exigrep"] || "/usr/sbin/exigrep"
                @mainlog = config.pluginconf["exim.paths.mainlog"] || "/var/log/exim/main.log"
            end

            action "mailq" do
                mailq = runcmd("#{@exiqgrep} #{exigrep_limiters.join ' '}")
                mailq = parse_mailq_output(mailq)

                reply[:mailq] = mailq
                reply[:size] = mailq.size
                reply[:frozen] = mailq.inject(0) {|i, q| q[:frozen] ? i += 1 : i }
            end

            action "size" do
                begin
                    size.each_pair do |k,v|
                        reply[k] = v
                    end
                rescue Exception => e
                    reply.fail "Failed to find the queue size, exiqgrep said: #{e}"
                end
            end

            action "summarytext" do
                reply[:summary] = summarytext
            end

            action "summary" do
                qsumm = summarytext

                reply[:summary] = []

                qsumm.each do |q|
                    domain = nil

                    if q =~ /^\W+(\d+)\W+(\d+\w+)\W+(\w+)\W+(\w+)\W+(.+)$/
                        domain = {}

                        domain[:count] = $1
                        domain[:volume] = $2
                        domain[:oldest] = $3
                        domain[:newest] = $4
                        domain[:domain] = $5

                        reply[:summary] << domain unless $5 == "TOTAL" && $1 =~ /\d+/
                    end
                end
            end

            action "retrymsg" do
                validate :msgid, :shellsafe

                operate_on_msg(request[:msgid]) do |id|
                    runcmd("#{@exim} -M #{id}", true, "mcollective exim agent retrying #{id}")
                    reply[:status] = "Message #{id} has been retried"
                end
            end

            action "addrecipient" do
                validate :msgid, :shellsafe
                validate :recipient, :shellsafe

                operate_on_msg(request[:msgid]) do |id|
                    runcmd("#{@exim} -Mar #{id} '#{request[:recipient]}'")
                    reply[:status] = "#{request[:recipient]} has been added to message #{id}"
                end
            end

            action "setsender" do
                validate :msgid, :shellsafe
                validate :sender, :shellsafe

                operate_on_msg(request[:msgid]) do |id|
                    runcmd("#{@exim} -Mes #{id} '#{request[:sender]}'")
                    reply[:status] = "#{request[:sender]} has been set as the sender of message #{id}"
                end
            end

            action "markdelivered" do
                validate :msgid, :shellsafe

                if request.include?(:recipient)
                    validate :recipient, :shellsafe
                    mode = :recipient
                else
                    mode = :msgid
                end

                operate_on_msg(request[:msgid]) do |id|
                    if mode == :recipient
                        runcmd("#{@exim} -Mmd #{id} '#{request[:recipient]}'")
                        reply[:status] = "Recipient #{request[:recipient]} on #{id} has been marked as delivered"
                    else
                        runcmd("#{@exim} -Mmad #{id}")
                        reply[:status] = "#{id} has been marked as delivered"
                    end
                end
            end

            action "freeze" do
                validate :msgid, :shellsafe

                operate_on_msg(request[:msgid]) do |id|
                    runcmd("#{@exim} -Mf #{id}")
                    reply[:status] = "Message #{id} has been frozen"
                end
            end

            action "thaw" do
                validate :msgid, :shellsafe

                operate_on_msg(request[:msgid]) do |id|
                    runcmd("#{@exim} -Mt #{id}")
                    reply[:status] = "Message #{id} has been unfrozen"
                end
            end

            action "giveup" do
                validate :msgid, :shellsafe

                operate_on_msg(request[:msgid]) do |id|
                    runcmd("#{@exim} -Mg #{id}")
                    reply[:status] = "Message #{id} has been bounced"
                end
            end

            action "rm" do
                validate :msgid, :shellsafe

                operate_on_msg(request[:msgid]) do |id|
                    runcmd("#{@exim} -Mrm #{id}")
                    reply[:status] = "Message #{id} has been removed"
                end
            end

            action "exiwhat" do
                reply[:exiwhat] = runcmd(@exiwhat)
            end

            action "rmbounces" do
                rm(:bounce)
            end

            action "rmfrozen" do
                rm(:frozen)
            end

            action "runq" do
                runcmd("#{@exim} -v -q", true)
                reply[:status] = "Queue run has been requested"
            end

            action "delivermatching" do
                validate :pattern, :shellsafe

                runcmd("#{@exim} -v -R '#{request[:pattern]}'", true)
                reply[:status] = "Delivery for pattern #{request[:pattern]} has been scheduled"
            end

            action "testaddress" do
                validate :address, :shellsafe

                reply[:routing_information] = runcmd("#{@exim} -bt '#{request[:address]}'")
            end

            action "exigrep" do
                validate :pattern, :shellsafe

                matches = runcmd("#{@exigrep} '#{request[:pattern]}' #{@mainlog}")

                reply.fail! "No lines matched #{request[:pattern]}" if matches.empty?

                reply[:matches] = matches
            end

            private
            def rm(type)
                if type == :bounce
                    exigreparg = "-f '<>'"
                elsif type == :frozen
                    exigreparg = "-z"
                else
                    raise "Don't know how to rm messages of type #{type}"
                end

                messages = runcmd("#{@exiqgrep} #{exigreparg} -c")

                if messages =~ /(\d+) matches out of (\d+) messages/
                    messages = $1.to_i

                    if messages > 0
                        reply[:output] = runcmd("#{@exiqgrep} -i #{exigreparg}| #{@xargs} #{@exim} -Mrm")
                        reply[:status] = "#{messages} messages deleted"
                        reply[:count] = messages
                    else
                        reply.fail! "No #{type} messages found on this server"
                    end
                else
                    reply.fail! "Could not determine #{type} message count: #{messages}"
                end
            end

            def size
                totalsize = runcmd("#{@exiqgrep} #{exigrep_limiters.join ' '} -c")
                frozensize = runcmd("#{@exiqgrep} #{exigrep_limiters.join ' '} -c -z")

                size = {:matched => 0, :total => 0, :frozen => 0}

                if totalsize =~ /(\d+) matches out of (\d+) messages/
                    size[:matched] = $1.to_i
                    size[:total] = $2.to_i
                else
                    raise "Failed to find the queue size, exiqgrep said: #{totalsize}"
                end

                if frozensize =~ /(\d+) matches out of (\d+) messages/
                    size[:frozen] = $1.to_i
                end

                return size
            end

            def operate_on_msg(msgid)
                if validid?(msgid) && hasmsg?(msgid)
                    yield(msgid)
                end
            end

            def hasmsg?(id, shouldfail=true)
                unless File.exist?("#{@spool}/#{id}-D") || File.exist?("#{@spool}/#{id}-H")
                    Log.debug("Could not find #{@spool}/#{id}-D or #{@spool}/#{id}-H")
                    reply.fail! "No message matching #{id}" if shouldfail
                    return false
                else
                    return true
                end
            end

            def validid?(msgid, shouldfail=true)
                return true if msgid == ""

                if shouldfail
                    reply.fail! "Did not receive a valid message id" unless msgid =~ /^\w+-\w+-\w+$/
                else
                    return false
                end

                return true
            end

            def summarytext
                runcmd("#{@mailq} 2>&1 | #{@exiqsumm}")
            end

            # parses requests for exigrep common limiters and returns an array of exigrep arguments
            def exigrep_limiters
                args = []

                get_request(:limit_sender, :shellsafe) {|val| args << "-f #{val}"}
                get_request(:limit_recipient, :shellsafe) {|val| args << "-r #{val}"}
                get_request(:limit_younger_than, :shellsafe) {|val| args << "-y #{val}"}
                get_request(:limit_older_than, :shellsafe) {|val| args << "-o #{val}"}
                get_request(:limit_frozen_only, :boolean) {|val| args << "-z"}
                get_request(:limit_unfrozen_only, :boolean) {|val| args << "-x"}

                args
            end

            # runs a command and returns the output, fails if exit code is non zero
            def runcmd(command, background = false, psname = nil)
                Log.debug("Running #{command}: background: #{background}")

                unless background
                    out = ""
                    err = ""

                    status = run(command, :stdout => out, :stderr => err, :chomp => true)

                    reply.fail!("Command #{command} failed with status #{status} and error: #{err}") unless status == 0

                    return out
                else
                    pid = fork do
                        $0 = psname if psname

                        ::Process.setsid
                        run(command)
                    end

                    ::Process.detach(pid)
                end
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

            # takes a block, pass the value of the key to the block if its present
            # and passes validation
            def get_request(key, validation)
                if request.include?(key)
                    if validation == :boolean
                        unless [TrueClass, FalseClass].include?(request[key].class)
                            raise "#{key} should be boolean"
                        end
                    else
                        validate key, validation
                    end

                    yield(request[key])
                end
            end
        end
    end
end
