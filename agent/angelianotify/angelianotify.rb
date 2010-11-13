module MCollective
    module Agent
        # A SimpleRPC plugin that uses the Angelia notify system to send messages.
        #
        # Messages can be sent using the normal mc-rpc command:
        #
        # mc-rpc angelianotify sendmsg message="hello world" recipient="xmpp://you@your.com" subject="test" -v
        #
        # For information about Angelia see http://github.com/ripienaar/angelia
        class Angelianotify<RPC::Agent
            require 'angelia'

            metadata    :name        => "SimpleRPC Plugin for The Angelia Nagios Notifier",
                        :description => "Agent to send messages via angelia",
                        :author      => "R.I.Pienaar",
                        :license     => "Apache License 2.0",
                        :version     => "1.2",
                        :url         => "http://mcollective-plugins.googlecode.com/",
                        :timeout     => 2

            def startup_hook
                @configfile = @config.pluginconf["angelia.configfile"] || "/etc/angelia/angelia.cfg"
            end

            action "sendmsg" do
                validate :recipient, :shellsafe
                validate :message, :shellsafe
                validate :subject, :shellsafe if request.include?(:subject)

                begin
                    angelia = Angelia::Config.new(@configfile, false)

                    if request.include?(:subject)
                        msg = Angelia::Message.new(request[:recipient], request[:message], request[:subject], "")
                    else
                        msg = Angelia::Message.new(request[:recipient], request[:message], "", "")
                    end

                    unless angelia.plugins.include?(msg.recipient.protocol.capitalize)
                        reply.fail! "Don't know how to handle protocol #{msg.recipient.protocol.capitalize}"
                    end

                    Angelia::Spool.createmsg msg

                    reply[:msg] = "Spooled message for #{request[:recipient]}"
                rescue Exception => e
                    reply.fail! "Failed to send message: #{e}"
                end
            end
        end
    end
end
# vi:tabstop=4:expandtab:ai
