module MCollective
    module Agent
        # TODO: 
        #  - paths should be configurable
        #  - sometimes leaves zombies around
        class Exim
            attr_reader :timeout, :meta
            def initialize
                @timeout = 5
                @meta = {:license => "GPLv2",
                         :author => "R.I.Pienaar <rip@devco.net>",
                         :url => "http://code.google.com/p/mcollective-plugins/"}

                @exim = "/usr/sbin/exim"
                @mailq = "/usr/bin/mailq"
                @exiqsumm = "/usr/sbin/exiqsumm"
                @exiwhat = "/usr/sbin/exiwhat"
                @exiqgrep = "/usr/sbin/exiqgrep"
                @xargs = "/usr/bin/xargs"
                @spool = "/var/spool/exim/input"
            end

            def handlemsg(msg, connection)
                req = msg[:body]
                command = req[:command]

                begin
                    # Validate everything we get passed, saves having to do it later
                    # every time we use it
                    unless req[:recipient] == ""
                        raise("Invalid email address") unless validemail?(req[:recipient])
                    end

                    unless req[:sender] == ""
                        raise("Invalid email address") unless validemail?(req[:sender])
                    end

                    unless req[:msgid] == ""
                        raise("Invalid msgid") unless validid?(req[:msgid])
                        raise("No such message") unless hasmsg?(req[:msgid])
                    end

                    case command
                        when "mailq"
                            mailq

                        when "summary"
                            summary

                        when "retrymsg"
                            retrymsg(req[:msgid])

                        when "addrecipient"
                            addrecipient(req[:msgid], req[:recipient])

                        when "setsender"
                            setsender(req[:msgid], req[:sender])

                        when "markmsgdelivered"
                            markmsgdelivered(req[:msgid])

                        when "markrecipdelivered"
                            markrecipdelivered(req[:msgid], req[:recipient])
 
                        when "freeze"
                            freeze(req[:msgid])
 
                        when "thaw"
                            thaw(req[:msgid])
 
                        when "giveup"
                            giveup(req[:msgid])
 
                        when "rm"
                            rm(req[:msgid])

                        when "exiwhat_text"
                            exiwhat_text

                        when "rmbounces"
                            rmbounces

                        when "rmfrozen"
                            rmfrozen

                        when "runq"
                            runq

                        when "delivermatching"
                            delivermatching(req[:queuematch])

                        when "testaddress"
                            testaddress(req[:recipient])
                    end
                rescue Exception => e
                    e.to_s
                end
            end

            def help
            <<-EOH
            Foo
            EOH
            end

            # helper functions for talking to exim
            private

            # Runs a command in the background, totally dissociated from the current
            # process and you will not have access to any input/output of the proces
            def runbackground(command)
                fork do
                    Process.setsid
                    Dir.chdir('/tmp')
                    STDIN.reopen('/dev/null')
                    STDOUT.reopen('/dev/null', 'a')
                    STDERR.reopen('/dev/null', 'a')
                    system(command)
                end
            end
    
            # Runs a command and throws an exception if the return code indicates an error
            # else return the output.  
            # 
            # If background is true the command will be run in the background and forgot about
            # no sensible exit state information will be available etc
            def runcmd(command, background=false)
                out = ""
    
                if background
                    runbackground(command)
                    out = "Request has been submitted for background processing"
                    return(out)
                else
                    out = %x{#{command} 2>&1}
    
                    return(out) if $? == 0
                end
    
                raise out
            end
    
            # Get's the mail queue and returns it as an array of openstructs
            #
            # Each array item will have the following properties:
            # * recipients - array of recipients
            # * frozen - true if the message is frozen
            # * age - the age of the message as reported by mailq
            # * size - size of the message as reported by mailq
            # * msgid - the exim message id
            # * sender - the sender address
            def mailq
                mailq = runcmd(@mailq)
    
                messages = Array.new
                msg = nil
    
                mailq.each do |m|
                    if m =~ /^\s*(.+?)\s+(.+?)\s+(.+-.+-.+) (<.*>)/
                        msg = {}
                        msg[:recipients] = Array.new
                        msg[:frozen] = false
    
                        msg[:age] = $1
                        msg[:size] = $2
                        msg[:msgid] = $3
                        msg[:sender] = $4
    
                        msg[:frozen] = true if m =~ /frozen/
                    elsif m =~ /\s+(\S+?)@(.+)/ and msg
                        msg[:recipients] << "#{$1}@#{$2}"
                    elsif m =~ /^$/ && msg
                        messages << msg
                        msg = nil
                    end
                end
    
                messages
            end
    
            # Gets the size of the mailq
            def size
                mailq.size
            end
    
            # Get the actual text from exiqsumm
            def summarytext
                runcmd("#{@mailq} 2>&1 | #{@exiqsumm}")
            end
    
            # Returns a parsed array of exiqsumm output
            def summary
                qsumm = summarytext
                
                stats = Array.new
                qsumm.each do |q|
                    domain = nil
    
                    if q =~ /^\W+(\d+)\W+(\d+\w+)\W+(\w+)\W+(\w+)\W+(.+)$/
                        domain = {}
    
                        domain[:count] = $1
                        domain[:volume] = $2
                        domain[:oldest] = $3
                        domain[:newest] = $4
                        domain[:domain] = $5
    
                        stats << domain unless $5 == "TOTAL" && $1 =~ /\d+/
                    end
                end
    
                stats
            end
    
            # Retries a message based on its msgid
            def retrymsg(msgid)
                runcmd("#{@exim} -d -M #{msgid}", true)
            end
    
            # Add a recipient to a message
            def addrecipient(msgid, recipient)
                runcmd("#{@exim} -Mar #{msgid} '#{recipient}'")
            end
    
            # Set the sender of a message by msgid
            def setsender(msgid, sender)
                runcmd("#{@exim} -Mes #{msgid} '#{sender}'")
            end
    
            # Mark an entire message as delivered
            def markmsgdelivered(msgid)
                runcmd("#{@exim} -Mmad #{msgid}")
            end
    
            # Marks a single recipient on a message as delivered
            def markrecipdelivered(msgid, recipient)
                runcmd("#{@exim} -Mmd #{msgid} '#{recipient}'")
            end
    
            # Freeze a message
            def freeze(msgid)
                runcmd("#{@exim} -Mf #{msgid}")
            end
    
            # Unfreeze a message
            def thaw(msgid)
                runcmd("#{@exim} -Mt #{msgid}")
            end
    
            # Gives up on a message with NDR
            def giveup(msgid)
                runcmd("#{@exim} -Mg #{msgid}")
            end
    
            # Removes a message without NDR
            def rm(msgid)
                runcmd("#{@exim} -Mrm #{msgid}")
            end
    
            # Returns the text of exiwhat
            def exiwhat_text
                runcmd(@exiwhat)
            end
    
            # Deletes all mail with a sender of <>
            def rmbounces
                out = %x{#{@exiqgrep} -i -f '<>' 2>&1}.split("\n").join(' ')

                raise("No bounce mail found on this server") unless out =~ /-/

                runcmd("#{@exiqgrep} -i -f '<>'| #{@xargs} #{@exim} -Mrm")
            end
    
            # Deletes all frozen messages
            def rmfrozen
                out = %x{#{@exiqgrep} -i -z 2>&1}.split("\n").join(' ')

                raise("No frozen mail found on this server") unless out =~ /-/

                runcmd("#{@xargs} #{@exim} -Mrm #{out}") if out
            end
    
            # Does a normal mail queue run in the background
            def runq
                runcmd("#{@exim} -v -q", true)
            end
    
            # Delivers all messages matching a patten
            def delivermatching(pattern)
                runcmd("#{@exim} -v -R '#{pattern}'", true)
            end
    
            # Does a routing test
            def testaddress(address)
                runcmd("#{@exim} -bt '#{address}'")
            end

            # Validates a messageid
            def validid?(msgid)
                msgid =~ /^\w+-\w+-\w+$/
            end

            # Simple/naive email validation
            def validemail?(email)
                email =~ /^\S+\@\S+$/
            end

            # Checks if there's a data or headers file for a given mail id
            def hasmsg?(id)
                File.exist?("#{@spool}/#{id}-D") || File.exist?("#{@spool}/#{id}-H") ? true : false
            end
        end
    end
end

# vi:tabstop=4:expandtab:ai:filetype=ruby
