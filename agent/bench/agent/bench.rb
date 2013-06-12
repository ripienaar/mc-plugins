module MCollective
  module Agent
    class Bench<RPC::Agent
      def startup_hook
        @basedir = @config.pluginconf.fetch("bench.basedir", "/tmp/mcollective-bench")
        @logsdir = File.join(@basedir, "logs")
        @pidsdir = File.join(@basedir, "pids")
        @server_config = @config.configfile

        @mcollectived = @config.pluginconf.fetch("bench.mcollectived", nil)
        @ruby = @config.pluginconf.fetch("bench.ruby", "/usr/bin/ruby")

        unless @mcollectived
          if File.exist?("/usr/sbin/mcollectived")
            @mcollectived = "/usr/sbin/mcollectived"
          elsif File.exist?("/opt/puppet/sbin/mcollectived")
            @mcollectived = "/opt/puppet/sbin/mcollectived"
          else
            raise "Cannot find mcollectived please configure bench.mcollectived"
          end
        end

        unless File.exist?(@ruby)
          if File.exist?("/opt/puppet/bin/ruby")
            @ruby = "/opt/puppet/bin/ruby"
          end
        end

        @collectivedir = File.join(@basedir, "collective")

        FileUtils.mkdir_p @basedir
        FileUtils.mkdir_p @logsdir
        FileUtils.mkdir_p @pidsdir
      end

      action "destroy" do
        stop_all_members

        FileUtils.rm_rf @collectivedir

        instances_stats
      end

      action "create_members" do
        reply.fail!("Collective has already been created") if File.directory?(@collectivedir)

        FileUtils.mkdir_p @collectivedir

        membercount = Integer(request[:count] || 10)
        brokerhost = request[:activemq_host] || @config.pluginconf.fetch(".activemq.pool.1.host", nil)

        raise "Cannot figure out broker host, supply :activemq_host or set plugin.activemq.pool.1.host" unless brokerhost

        membercount.times do |i|
          identity = "#{@config.identity}-#{i}"
          logfile = File.join(@logsdir, "mcollectived-#{i}.log")

          create_member(identity, logfile, brokerhost)
        end

        reply[:status] = "Created %d members in %s" % [membercount, @collectivedir]

        instances_stats
      end

      action "list" do
        reply[:members] = get_members
      end

      action "status" do
        members = get_members

        reply[:instance_count] = members.size
        reply[:members] = []
        members.each do |member|
          reply[:members] << {:name => member, :pid => get_member_pid(member)}
        end

        instances_stats
      end

      action "start" do
        start_all_members
        instances_stats
      end

      action "stop" do
        stop_all_members
        instances_stats
      end

      def instances_stats
        reply[:instance_count] = get_members.size

        reply[:instances_running] = get_members.map do |member|
          get_member_pid(member)
        end.compact.size

        reply[:instances_stopped] = reply[:instance_count] - reply[:instances_running]
      end

      def start_all_members
        get_members.each do |member|
          start_member(member)
          sleep 0.2
        end
      end

      def stop_all_members
        get_members.each do |member|
          stop_member(member)
        end
      end

      def stop_member(identity)
        pid = member_running?(identity)
        if pid
          Log.info("Stopping collective member #{identity} with pid #{pid}")
          ::Process.kill(2, Integer(pid))
          FileUtils.rm(get_member_pid(identity)) rescue nil
        end
      end

      def start_member(identity)
        reply.fail! "You need to create a collective first using rake create" if get_members.size == 0

        return true if member_running?(identity)

        memberdir = member_path(identity)
        pid = pid_path(identity)
        libdir = @config.libdir.join(":")
        config = File.join(memberdir, "etc", "server.cfg")

        cmd = "#{@ruby} -I #{libdir} #{@mcollectived} --config #{config} --pidfile #{pid}"

        Log.info("Starting member #{identity} with #{cmd} in #{memberdir}")

        status = run(cmd, :cwd => memberdir)
      end

      def member_running?(identity)
        pid = get_member_pid(identity)

        return false unless pid

        if File.directory?("/proc")
          return Integer(pid) if File.exist?("/proc/#{pid}")
        end

        false
      end

      def get_member_pid(identity)
        pidfile = pid_path(identity)

        return nil unless File.exist?(pidfile)

        Integer(File.read(pidfile))
      end

      def get_members
        Dir.entries(@collectivedir).reject{|f| f.start_with?(".")}
      rescue
        []
      end

      def pid_path(identity)
        File.join(@pidsdir, "#{identity}.pid")
      end

      def member_path(identity)
        File.join(@collectivedir, identity)
      end

      def create_member(identity, logfile, brokerhost)
        memberdir = member_path(identity)
        memberconfig = File.join(memberdir, "etc", "server.cfg")

        FileUtils.mkdir_p(File.join(memberdir, "etc"))

        Log.info("Creating member %s in %s" % [identity, memberdir])

        render_config(@server_config, memberconfig, identity, logfile, brokerhost)
      end

      def render_config(source, dest, identity, log, brokerhost)
        source_lines = File.readlines(source)

        File.open(dest, "w") do |f|
          source_lines.each do |line|
            if line =~ /^identity/
              line = "identity = %s" % identity
            elsif line =~ /^logfile/
              line = "logfile = %s" % log
            elsif line =~ /plugin.activemq.pool.1.host/
              line = "plugin.activemq.pool.1.host = %s" % brokerhost
            end

            f.puts line
          end

          f.puts "plugin.bench.activate_agent = false"
        end
      end
    end
  end
end
