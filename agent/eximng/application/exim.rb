class MCollective::Application::Exim<MCollective::Application
  description "MCollective Exim Manager"
  usage "mco exim [mailq|size|summary|exiwhat|rmbounces|rmfrozen|runq]"
  usage "mco exim runq <pattern>"
  usage "mco exim [retry|markdelivered|freeze|thaw|giveup|rm] <message id>"
  usage "mco exim [addrecipient|markdelivered] <message id> <recipient>"
  usage "mco exim setsender <message id> <sender>"
  usage "mco exim <message matchers> [mailq|size]"
  usage "mco exim test <address>"
  usage "mco exim exigrep pattern"

  VALID_COMMANDS = ["mailq", "size", "summary", "exiwhat", "rmbounces", "rmfrozen", "runq", "addrecipient", "markdelivered", "setsender", "retry", "freeze", "thaw", "giveup", "rm", "delivermatching", "exigrep", "test"]
  MSGID_REQ_COMMANDS = ["setsender", "retry", "markdelivered", "freeze", "thaw", "giveup", "rm"]
  RECIP_OPT_COMMANDS = ["markdelivered"]
  RECIP_REQ_COMMANDS = ["addrecipient"]

  option :limit_sender,
         :description    => "Match sender pattern",
         :arguments      => ["--match-sender SENDER", "--limit-sender"],
         :required       => false

  option :limit_recipient,
         :description    => "Match recipient pattern",
         :arguments      => ["--match-recipient RECIPIENT", "--limit-recipient"],
         :required       => false

  option :limit_younger_than,
         :description    => "Match younger than seconds",
         :arguments      => ["--match-younger SECONDS", "--limit-younger"],
         :required       => false

  option :limit_older_than,
         :description    => "Match older than seconds",
         :arguments      => ["--match-older SECONDS", "--limit-older"],
         :required       => false

  option :limit_frozen_only,
         :description    => "Match only frozen messages",
         :arguments      => ["--match-frozen", "--limit-frozen"],
         :type           => :bool,
         :required       => false

  option :limit_unfrozen_only,
         :description    => "Match only active messages",
         :arguments      => ["--match-active", "--limit-active"],
         :type           => :bool,
         :required       => false

  def post_option_parser(configuration)
    configuration[:command] = ARGV.shift if ARGV.size > 0

    if MSGID_REQ_COMMANDS.include?(configuration[:command])
      if ARGV.size > 0
        configuration[:message_id] = ARGV[0]
      else
        raise "#{configuration[:command]} requires a message id"
      end
    end

    if RECIP_REQ_COMMANDS.include?(configuration[:command])
      if ARGV.size == 2
        configuration[:message_id] = ARGV[0]
        configuration[:recipient] = ARGV[1]
      else
        raise "#{configuration[:command]} requires a message id and recipient"
      end
    end

    if RECIP_OPT_COMMANDS.include?(configuration[:command])
      if ARGV.size == 2
        configuration[:recipient] = ARGV[1]
      end
    end
  end

  def validate_configuration(configuration)
    raise "Please specify a command, see --help for details" unless configuration[:command]

    raise "Unknown command #{configuration[:command]}, see --help for full help" unless VALID_COMMANDS.include?(configuration[:command])

    if configuration.include?(:message_id)
      raise "Invalid message id format for id #{configuration[:message_id]}" unless configuration[:message_id] =~ /^\w+-\w+-\w+$/
    end
  end

  def exigrep_command(util)
    if ARGV.empty?
      raise("The exigrep command requires a pattern")
    else
      configuration[:pattern] = ARGV.first
    end

    puts util.exigrep(configuration)
  end

  def test_command(util)
    if ARGV.empty?
      raise("The test command requires an address")
    else
      configuration[:address] = ARGV.first
    end

    puts util.test(configuration)
  end

  def runq_command(util)
    unless ARGV.empty?
      configuration[:pattern] = ARGV.first
    end

    puts util.runq(configuration)
  end

  def setsender_command(util)
    if ARGV.size == 2
      configuration[:sender] = ARGV.first
    else
      raise "Please supply a sender"
    end

    puts util.setsender(configuration)
  end

  def main
    MCollective::Util.loadclass("MCollective::Util::EximNG")

    mc = rpcclient("eximng", :options => options)
    util = MCollective::Util::EximNG.new(mc)

    cmd = "#{configuration[:command]}_command"

    # if there are local foo_command methods, use that to
    # render foo, else use M::U::EximNG#foo else fail
    if respond_to?(cmd)
      send(cmd, util)
    elsif util.respond_to?(configuration[:command])
      puts util.send(configuration[:command], configuration)
    else
      raise "Support for #{configuration[:command]} has not yet been implimented"
    end

    puts

    mc.disconnect
  end
end
