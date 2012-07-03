module MCollective
    module Agent
        class Libvirt<RPC::Agent
            require 'libvirt'

            action "hvinfo" do
                conn = connect

                begin
                    nodeinfo = conn.node_get_info

                    [:model, :memory, :cpus, :mhz, :nodes, :sockets, :cores, :threads].each do |i|
                        reply[i] = nodeinfo.send(i)
                    end

                    [:type, :version, :uri, :max_vcpus].each do |i|
                        reply[i] = conn.send(i)
                    end

                    # not implemented on all hypervisors
                    [:num_of_defined_domains, :num_of_defined_interfaces, :num_of_defined_networks, :num_of_defined_storage_pools,
                     :num_of_domains, :num_of_interfaces, :num_of_networks, :num_of_nodedevices, :num_of_nwfilters, :num_of_secrets,
                     :num_of_storage_pools].each do |i|
                        begin
                            reply[i] = conn.send(i)
                        rescue
                            reply[i] = -1
                        end
                    end

                    reply[:active_domains] = []
                    conn.list_domains.each do |id|
                        domain = conn.lookup_domain_by_id(id)
                        reply[:active_domains] << domain.name

                        domain.free
                    end
                    reply[:active_domains].sort!

                    reply[:inactive_domains] = conn.list_defined_domains.sort

                    reply[:facts] = PluginManager["facts_plugin"].get_facts if request[:facts]
                rescue Exception => e
                    reply.fail! "Could not load hvm info: #{e}"
                ensure
                    close(conn)
                end
            end

            action "domaininfo" do
                validate :domain, String

                conn = connect

                begin
                    has_domain?(request[:domain], conn)

                    domain = conn.lookup_domain_by_name(request[:domain])
                    info = domain.info

                    reply[:autostart] = domain.autostart?
                    reply[:vcpus] = info.nr_virt_cpu
                    reply[:memory] = info.memory
                    reply[:max_memory] = info.max_mem
                    reply[:cputime] = info.cpu_time
                    reply[:state] = info.state
                    reply[:state_description] = virtstates[info.state]
                    reply[:uuid] = domain.uuid
                    reply[:persistent] = domain.persistent?

                    # not on all versions of libvirt
                    begin
                        reply[:has_current_snapshot] = domain.has_current_snapshot?
                        reply[:has_managed_save] = domain.has_managed_save?
                        reply[:snapshots] = domain.list_snapshots
                        reply[:num_of_snapshots] = domain.num_of_snapshots
                    rescue
                    end
                rescue Exception => e
                    reply.fail! "Could not load domain %s: %s" % [request[:domain], e]
                ensure
                    domain.free if domain
                    close(conn)
                end
            end

            action "domainxml" do
                validate :domain, String

                conn = connect

                begin
                    has_domain?(request[:domain], conn)

                    domain = conn.lookup_domain_by_name(request[:domain])
                    reply[:xml] = domain.xml_desc
                rescue Exception => e
                    reply.fail! "Could not load domain %s: %s" % [request[:domain], e]
                ensure
                    domain.free if domain

                    close(conn)
                end
            end

            action "definedomain" do
                validate :xmlfile, String if request.include?[:xmlfile]
                validate :xml, String if request.include?[:xml]
                validate :domain, String

                reply.fail!("Can't find XML file defining instance") unless File.exist?(request[:xmlfile])

                begin
                    conn = connect

                    if request[:xmlfile]
                        xml = File.read(request[:xmlfile])
                    elsif request[:xml]
                        xml = File.read(request[:xml])
                    else
                        reply.fail!("Need either xmlfile or xml parameters to define a domain")
                    end


                    if request[:permanent]
                        conn.define_domain_xml(xml)
                    else
                        conn.create_domain_xml(xml)
                    end

                    domain = conn.lookup_domain_by_name(request[:domain])
                    reply[:state] = domain.info.state
                    reply[:state_description] = virtstates[reply[:state]]
                rescue Exception => e
                    reply.fail! "Could not define domain %s: %s" % [request[:domain], e]
                ensure
                    domain.free if domain

                    close(conn)
                end
            end

            action "undefinedomain" do
                validate :domain, String

                begin
                    conn = connect

                    has_domain?(request[:domain], conn)

                    domain = conn.lookup_domain_by_name(request[:domain])

                    if request[:destroy] && domain.active?
                        Log.info("Attempting to destroy domain %s on request of %s" % [request[:domain], request.caller])
                        domain.destroy
                    end

                    Log.info("Attempting to undefine domain %s on request of %s" % [request[:domain], request.caller])

                    domain.undefine

                    reply[:status] = request[:domain] + " undefined"
                rescue Exception => e
                    reply.fail! "Could not undefine domain %s: %s" % [request[:domain], e]
                ensure
                    domain.free if domain
                    close(conn)
                end
            end

            [:destroy, :shutdown, :suspend, :resume, :create, :reboot].each do |act|
                action act do
                    validate :domain, String

                    reply[:state] = domain_action(request[:domain], act)
                    reply[:state_description] = virtstates[reply[:state]]
                end
            end

            alias :start_action :create_action

            private
            def connect
                url = @config.pluginconf["libvirt.url"] || "qemu:///system"

                conn = ::Libvirt::open(url)

                raise "Could not connect to hypervisor" if conn.closed?

                conn
            end

            def close(conn)
                if conn && !conn.closed?
                    conn.close
                end
            end

            def domains(conn)
                domains = []
                conn.list_domains.each do |id|
                    domain = conn.lookup_domain_by_id(id)
                    domains << domain.name
                    domain.free
                end

                domains << conn.list_defined_domains

                domains.flatten.sort
            end

            def has_domain?(domain, conn)
                raise "Unknown domain #{request[:domain]}" unless domains(conn).include?(request[:domain])
            end

            def virtstates
                {0 => "No state",
                 1 => "Running",
                 2 => "Blocked on resource",
                 3 => "Paused",
                 4 => "Shutting down",
                 5 => "Shut off",
                 6 => "Crashed"}
            end

            def domain_action(name, action)
                conn = connect

                begin
                    has_domain?(request[:domain], conn)

                    domain = conn.lookup_domain_by_name(name)
                    domain.send(action.to_sym)

                    return domain.info.state
                rescue Exception => e
                    reply.fail! "Could not #{action} domain %s : %s" % [request[:domain], e]
                ensure
                    domain.free if domain
                    close(conn)
                end
            end
        end
    end
end
