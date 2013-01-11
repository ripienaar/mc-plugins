require 'redis'
require 'ostruct'

module MCollective
  module Connector
    # A basic connector for mcollective using Redis.
    #
    # It is not aimed at large deployments more aimed as a getting
    # starter / testing style setup which would be easier for new
    # users to evaluate mcollective
    #
    # It supports direct addressing and sub collectives
    #
    # We'd also add a registration plugin for it and a discovery
    # plugin which means we can give a very solid fast first-user
    # experience using this
    class Redis<Base
      class ThreadsafeQueue
        require 'thread'
        require 'timeout'

        def initialize
          @queue = []
          @mutex = Mutex.new
          @cv =  ConditionVariable.new
        end

        def push(item)
          @mutex.synchronize do
            @queue.push(item)
          end

          @cv.signal
        end

        alias_method :<<, :push

        def pop
          @mutex.synchronize do
            while true
              if @queue.empty?
                begin
                  Timeout::timeout(5) do
                    @cv.wait(@mutex)
                  end
                rescue Timeout::Error
                  retry
                end
              else
                return @queue.shift
              end
            end
          end
        end
      end

      def initialize
        @config = Config.instance
        @sources = []
        @subscribed = false
      end

      def connect
        @receiver_redis = ::Redis.new :thread_safe => false
        @receiver_queue = ThreadsafeQueue.new
        @receiver_thread = nil

        @sender_redis = ::Redis.new :thread_safe => false
        @sender_queue = ThreadsafeQueue.new
        @sender_thread = nil

        start_sender_thread
      end

      def subscribe(agent, type, collective)
        unless @subscribed
          if PluginManager["security_plugin"].initiated_by == :client
            @sources << "mcollective::reply::%s::%d" % [@config.identity, $$]
          else
            @config.collectives.each do |collective|
              @sources << "%s::server::direct::%s" % [collective, @config.identity]
              @sources << "%s::server::agents" % collective
            end
          end

          @subscribed = true
          start_receiver_thread(@sources)
        end
      end

      def unsubscribe(agent, type, collective); end
      def disconnect; end

      def receive
        msg = @receiver_queue.pop
        return Message.new(msg.body, msg, :headers => msg.headers)
      end

      def publish(msg)
        Log.debug("About to publish to the sender queue")

        target = {:name => nil, :headers => {}, :name => nil}

        if msg.type == :direct_request
          msg.discovered_hosts.each do |node|
            target[:name] = "%s::server::direct::%s" % [msg.collective, node]
            target[:headers]["reply-to"] = "mcollective::reply::%s::%d" % [@config.identity, $$]

            Log.debug("Sending a direct message to Redis target '#{target[:name]}' with headers '#{target[:headers].inspect}'")

            @sender_queue << {:channel => target[:name],
                              :body => msg.payload,
                              :headers => target[:headers]}
          end
        else
          if msg.type == :reply
            target[:name] = msg.request.headers["reply-to"]

          elsif msg.type == :request
            target[:name] = "%s::server::agents" % msg.collective
            target[:headers]["reply-to"] = "mcollective::reply::%s::%d" % [@config.identity, $$]
          end


          Log.debug("Sending a broadcast message to Redis target '#{target[:name]}' with headers '#{target[:headers].inspect}'")

          @sender_queue << {:channel => target[:name],
                            :body => msg.payload,
                            :headers => target[:headers]}
        end
      end

      def start_receiver_thread(sources)
        @receiver_thread = Thread.new do
          begin
            @receiver_redis.subscribe(@sources) do |on|
              on.subscribe do |channel, subscriptions|
                Log.debug("Subscribed to %s" % channel)
              end

              on.message do |channel, message|
                begin
                  Log.debug("Got a message on %s: %s" % [channel, message])
                  decoded_msg = YAML.load(message)

                  new_message = OpenStruct.new
                  new_message.channel = channel
                  new_message.body = decoded_msg[:body]
                  new_message.headers = decoded_msg[:headers]

                  @receiver_queue << new_message
                rescue => e
                  Log.warn("Failed to receive from the receiver source: %s: %s" % [e.class, e.to_s])
                end
              end
            end
          rescue Exception => e
            Log.warn("The receiver thread lost connection to the Redis server: %s: %s" % [e.class, e.to_s])
            sleep 0.2
            retry
          end
        end

        Log.debug("Started receiver_thread %s" % @receiver_thread.inspect)
      end

      def start_sender_thread
        @sender_thread = Thread.new do
          loop do
            begin
              msg = @sender_queue.pop
              encoded = {:body => msg[:body], :headers => msg[:headers]}.to_yaml
              @sender_redis.publish(msg[:channel], encoded)
            rescue Exception => e
              Log.warn("Could not publish message to redis: %s: %s" % [e.class, e.to_s])
              sleep 0.2
              retry
            end
          end
        end

        Log.debug("Started sender_thread %s" % @sender_thread.inspect)
      end
    end
  end
end
