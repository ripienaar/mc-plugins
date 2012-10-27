module MCollective
  module Agent
    class Haproxy<RPC::Agent
      def startup_hook
        @socket_path = config.pluginconf.fetch("haproxy.socket", "/var/lib/haproxy/stats")
      end

      action "enable" do
        enable_disable_server(:enable, request[:backend], request[:server])
      end

      action "disable" do
        enable_disable_server(:disable, request[:backend], request[:server])
      end

      def enable_disable_server(action, backend, server)
        result = single_socket_command(@socket_path, "%s server %s/%s;" % [action, backend, server])

        unless result == ""
          reply[:status] = result
          reply.fail!("Could not %s server %s/%s: %s" % [action, backend, server, result])
        else
          reply[:status] = "OK"
        end
      end

      def single_socket_command(socket_path, command)
        socket = UNIXSocket.new(socket_path)

        Log.debug("Writing '%s' to socket '%s'" % [command, socket_path])

        socket.write(command)

        result = socket.gets.chomp
      ensure
        socket.close

        result
      end
    end
  end
end
