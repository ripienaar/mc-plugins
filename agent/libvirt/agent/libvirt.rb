module MCollective
    module Agent
        class Libvirt<RPC::Agent
            require 'libvirt'

            metadata    :name        => "libvirt",
                        :description => "SimpleRPC Libvirt Agent",
                        :author      => "R.I.Pienaar <rip@devco.net>",
                        :license     => "ASL2.0",
                        :version     => "0.1",
                        :url         => "http://devco.net/",
                        :timeout     => 10

            action "hvinfo" do
                conn = connect

                nodeinfo = conn.node_get_info

                [:model, :memory, :cpus, :mhz, :nodes, :sockets, :cores, :threads].each do |i|
                    reply[i] = nodeinfo.send(i)
                end

                [:type, :version, :uri, :node_free_memory, :max_vcpus].each do |i|
                    reply[i] = conn.send(i)
                end

                reply[:active_domains] = []
                conn.list_domains.each do |domain|
                    reply[:active_domains] << conn.lookup_domain_by_id(domain).name
                end
                reply[:active_domains].sort!

                reply[:inactive_domains] = conn.list_defined_domains.sort

                conn.close
            end

            action "domaininfo" do
                validate :domain, String

                conn = connect

                begin
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
                rescue Exception => e
                    reply.fail! "Could not load domain %s: %s" % [request[:domain], e]
                end

                conn.close
            end

            action "domainxml" do
                validate :domain, String

                conn = connect

                begin
                    domain = conn.lookup_domain_by_name(request[:domain])
                    reply[:xml] = domain.xml_desc
                rescue Exception => e
                    reply.fail! "Could not load domain %s: %s" % [request[:domain], e]
                end

                conn.close
            end

            [:destroy, :shutdown, :suspend, :resume, :create].each do |act|
                action act do
                    validate :domain, String

                    reply[:state] = domain_action(request[:domain], act)
                    reply[:state_description] = virtstates[reply[:state]]
                end
            end

            alias :start_action :create_action

            private
            def connect
                conn = ::Libvirt::open('qemu:///system')

                raise "Could not connect to hypervisor" if conn.closed?

                conn
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
                    domain = conn.lookup_domain_by_name(name)
                    domain.send(action.to_sym)

                    return domain.info.state
                rescue Exception => e
                    reply.fail! "Could not #{action} domain %s : %s" % [request[:domain], e]
                end
            end
        end
    end
end
