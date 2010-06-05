module MCollective
    module Agent
        # A SimpleRPC plugin that uses the Nagger notify system to send messages.
        #
        # Messages can be sent using the normal mc-rpc command:
        #
        # mc-rpc naggernotify sendmsg message="hello world" recipient="xmpp://you@your.com" subject="test" -v
        #
        # For information about Nagger see http://code.google.com/p/nagger/
        class Naggernotify<RPC::Agent
            require 'nagger'

            def startup_hook
                meta[:license] = "Apache License 2.0"
                meta[:author] = "R.I.Pienaar"
                meta[:version] = "1.1"
                meta[:url] = "http://mcollective-plugins.googlecode.com/"

                @timeout = 2

                @configfile = @config.pluginconf["nagger.configfile"] || "/etc/nagger/nagger.cfg"
            end

            def sendmsg_action
                validate :recipient, :shellsafe
                validate :message, :shellsafe
                validate :subject, :shellsafe
               
                begin
                    nagger = Nagger::Config.new(@configfile, false)
                    msg = Nagger::Message.new(request[:recipient], request[:message], request[:subject], "")

                    unless nagger.plugins.include?(msg.recipient.protocol.capitalize) 
                        reply.fail! "Don't know how to handle protocol #{msg.recipient.protocol.capitalize}" 
                    end

                    Nagger::Spool.createmsg msg

                    reply[:msg] = "Spooled message for #{request[:recipient]}"
                rescue Exception => e
                    reply.fail! "Failed to send message: #{e}"
                end
            end

            def help
                <<-EOH
                SimpleRPC Agent for Nagger
                ==========================

                This agent lets you send messages via MCollective to any recipient or protocol
                Nagger has a plugin for.

                For information about Nagger see http://code.google.com/p/nagger/

                ACTIONS:
                    sendmessage

                INPUT:
                    :message        The body of the message
                    :recipient      The Nagger recipient
                    :subject        The message subject

                OUTPUT:
                    :msg            A message indicating succcess
                EOH
            end
        end
    end
end
# vi:tabstop=4:expandtab:ai
