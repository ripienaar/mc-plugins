module MCollective
    module Agent
        class Rndc<RPC::Agent
            metadata    :name        => "rndc",
                        :description => "SimpleRPC RNDC Agent",
                        :author      => "R.I.Pienaar <rip@devco.net>",
                        :license     => "ASL2.0",
                        :version     => "0.2",
                        :url         => "http://www.devco.net/",
                        :timeout     => 5

            def startup_hook
                @rndc = "/usr/sbin/rndc"
            end

            ["reload", "freeze", "thaw"].each do |cmd|
                action cmd do
                    optional_zone_command(cmd)
                end
            end

            ["refresh", "retransfer", "notify", "sign"].each do |cmd|
                action cmd do
                    zone_command(cmd)
                end
            end

            ["reconfig", "querylog", "flush"].each do |cmd|
                action cmd do
                    rndc(cmd)
                end
            end

            action "status" do
                out = ""
                err = ""

                ret = run("#{@rndc} status", :stdout => out, :err => err, :chomp => true)

                reply.fail! "Failed to get rndc status: #{err}" if ret > 0

                out.lines.each do |line|
                    if line =~ /^(.+?): (.+)/
                        val = $2
                        var = $1.gsub(" ", "_").downcase.to_sym
                        reply[var] = val
                    end
                end
            end

            private
            def zone_command(command)
                validate :zone, :shellsafe

                rndc(command, request[:zone])
            end

            def optional_zone_command(command)
                if request.include?(:zone)
                    zone_command(command)
                else
                    rndc(command)
                end
            end

            def rndc(command, options=nil)
                cmd = [@rndc, command, options].flatten.compact.join(" ")

                Log.info("Running #{cmd}")

                status = run(cmd, :stdout => :out, :stderr => :err, :chomp => true)

                reply.fail! "#{cmd} returned #{status}" if status > 0
            end
        end
    end
end
