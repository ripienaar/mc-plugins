module MCollective
    module Agent
        require 'puppet'

        # An agent that uses Reductive Labs Puppet to manage packages
        #
        # See http://code.google.com/p/mcollective-plugins/
        #
        # Released under the terms of the GPL, same as Puppet
        class Package
            attr_reader :timeout, :meta

            def initialize
                @timeout = 120
                @log = Log.instance

                @meta = {:license => "GPLv2",
                         :author => "R.I.Pienaar <rip@devco.net>",
                         :url => "http://code.google.com/p/mcollective-plugins/"}
            end

            def handlemsg(msg, connection)
                req = msg[:body]
                package = req["package"]
                action = req["action"]

                @log.info("Doing package #{action} for package #{package}")

                output = "no output"
                status = "unknown"

                begin
                    if Puppet.version =~ /0.24/
                        Puppet::Type.type(:package).clear
                        pkg = Puppet::Type.type(:package).create(:name => package).provider
                    else
                        pkg = Puppet::Type.type(:package).new(:name => package).provider
                    end

                    case action
                        when /^install$/
                            if pkg.properties[:ensure] == :absent
                                pkg.send action
                            end

                        when /^update$/
                            if pkg.properties[:ensure] != :absent
                                pkg.send action
                            end

                        when /^(uninstall|purge)$/
                            if pkg.properties[:ensure] != :absent
                                pkg.send action
                            end

                        when "status"
                            # don't do anything, just return the status later
                             
                        else
                            raise("Unsupported action: #{action}")
                    end

                    pkg.flush

                    status = pkg.properties
                rescue Exception => e
                    output = "Failed: #{e}"
                end

                {:output => output,
                 :pkgstatus => status}
            end

            def help
                <<-EOH
                Package Agent
                =============

                Agent to manage packages using the Puppet package provider

                Accepted Messages
                -----------------

                The request should be a hash of action and package:

                {"action" => "update"
                 "package" => "zsh"}

                Possible actions are:
                install, update  - install or update to latest a package
                uninstall, purge - uninstall or purge a package
                status           - returns just the status of a package

                Purging for YUM means yum remove which will also remove without prompts
                anything that is dependant on the given package, use with care

                Returned Data
                -------------

                Returns a hash that maps to the package provider's properties method
                EOH
            end
        end
    end
end

# vi:tabstop=4:expandtab:ai:filetype=ruby
