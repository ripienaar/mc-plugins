module MCollective
  module Agent
    class Collective<RPC::Agent
      metadata    :name        => "collective",
                  :description => "Manage multiple mcollectived instances on a single node",
                  :author      => "R.I.Pienaar",
                  :license     => "ASL 2.0",
                  :version     => "0.6",
                  :url         => "http://devco.net/",
                  :timeout     => 60

      action "destroy" do
        stop_all_members

        FileUtils.rm_rf @collectivedir

        instances_stats
      end

      action "create_members" do
        reply.fail!("Collective has already been created") if File.directory?(@collectivedir)

        FileUtils.mkdir_p @collectivedir

        membercount = Integer(request[:count] || 10)
        version = request[:version] || "master"
        collective = request[:collective] || "mcollectivedev"
        subcollectives = request[:subcollective].split(",") rescue @config.collectives.reject{|c| c == collective}
        server = request[:server].split(",") || [@config.pluginconf["activemq.pool.1.host"], @config.pluginconf["activemq.pool.2.host"]]
        user = request[:user] || @config.pluginconf["activemq.pool.1.user"]
        pass = request[:password] || @config.pluginconf["activemq.pool.1.password"]
        port = request[:port] || @config.pluginconf["activemq.pool.1.port"]

        membercount.times do |i|
          identity = "#{@config.identity}-#{i}"

          create_member(identity, version, collective, subcollectives, server, port, user, pass)
        end

        reply[:status] = "Created %d members in %s" % [membercount, @collectivedir]

        instances_stats
      end

      action "clone_source_repo" do
        validate :gitrepo, :shellsafe
        validate :branch, :shellsafe

        Log.info("Cloning %s of %s into %s" % [request[:branch], request[:gitrepo], @clonedir])

        FileUtils.rm_rf(@clonedir) if File.exist?(@clonedir)

        command = "git clone -q %s %s --branch %s" % [request[:gitrepo], @clonedir, request[:branch]]

        reply[:status] = run(command, :stdout => :out, :stderr => :err, :chomp => true, :cwd => @basedir)

        reply.fail! "Failed to run '#{command}'" unless reply[:status] == 0
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
          sleep 0.5
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
        libdir = File.join(memberdir, "lib")
        config = File.join(memberdir, "etc", "server.cfg")

        cmd = "ruby -I #{libdir} bin/mcollectived --config #{config} --pidfile #{pid}"
        Log.info("Starting member #{identity} with #{cmd} in #{memberdir}")

        status = run("ruby -I #{libdir} bin/mcollectived --config #{config} --pidfile #{pid}", :cwd => memberdir)
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

      def create_member(identity, version, collective, subcollectives, stompserver, stompport, stompuser, stomppass)
        raise "Cannot find server.cfg template in #{@templatedir}" unless File.exist?(File.join(@templatedir, "server.cfg.erb"))

        memberdir = member_path(identity)
        membertemplate = File.join(@templatedir, "server.cfg.erb")
        memberconfig = File.join(memberdir, "etc", "server.cfg")

        Log.info("Creating member %s in %s using templates in %s" % [identity, memberdir, @templatedir])

        out = ""; err = ""
        cmd = "git clone -q file:///%s %s" % [@clonedir, memberdir]
        status = run(cmd, :stdout => out, :stderr => err, :chomp => true)
        raise("Cloning member #{identity} failed while running #{cmd}: #{err}") unless status == 0

        out = ""; err = ""
        cmd = "git checkout -q %s" % version
        status = run(cmd, :stdout => out, :stderr => err, :chomp => true, :cwd => memberdir)
        raise("Cloning member #{identity} failed while running #{cmd}: #{err}") unless status == 0

        render_template(membertemplate, memberconfig, binding)
        FileUtils.cp(get_random_template_file("classes"), File.join(memberdir, "etc", "classes.txt"))
        FileUtils.cp(get_random_template_file("facts"), File.join(memberdir, "etc", "facts.yaml"))
        FileUtils.cp_r(File.join(@pluginsdir, "."), File.join(memberdir, "plugins", "mcollective"))
      end

      def get_random_template_file(type)
        files = Dir.entries(File.join(@templatedir, type)).reject{|f| f.start_with?(".")}

        File.join(@templatedir, type, files[rand(files.size)])
      end

      def render_template(template, output, scope)
        tmpl = File.read(template)
        erb = ERB.new(tmpl, 0, "<>")
        File.open(output, "w") do |f|
          f.puts erb.result(scope)
        end
      end

      def startup_hook
        @basedir = @config.pluginconf["collective.basedir"] || "/tmp/collective"
        @logsdir = File.join(@basedir, "logs")
        @pidsdir = File.join(@basedir, "pids")
        @clonedir = File.join(@basedir, "source")
        @collectivedir = File.join(@basedir, "collective")
        @templatedir = File.join(File.dirname(__FILE__), "collective", "templates")
        @pluginsdir = File.join(File.dirname(__FILE__), "collective", "plugins")

        FileUtils.mkdir_p @basedir
        FileUtils.mkdir_p @logsdir
        FileUtils.mkdir_p @pidsdir
      end

    end
  end
end
