class MCollective::Application::Virt<MCollective::Application
    description "MCollective Libvirt Manager"

    usage "Usage: mco virt info"
    usage "Usage: mco virt info <domain>"
    usage "Usage: mco virt xml <domain>"
    usage "Usage: mco virt find <pattern>"
    usage "Usage: mco virt [stop|start|suspend|resume|destroy] <domain>"
    usage "Usage: mco virt domains"

    def post_option_parser(configuration)
        configuration[:command] = ARGV.shift if ARGV.size > 0
        configuration[:domain] = ARGV.shift if ARGV.size > 0
    end

    def validate_configuration(configuration)
        raise "Please specify a command, see --help for details" unless configuration[:command]

        if ["xml", "stop", "start", "suspend", "resume", "destroy", "find"].include?(configuration[:command])
            raise "%s requires a domain name, see --help for details" % [configuration[:command]] unless configuration[:domain]
        end
    end

    def info_command
        if configuration[:domain]
            printrpc virtclient.domaininfo(:domain => configuration[:domain])
        else
            printrpc virtclient.hvinfo
        end
    end

    def xml_command
        printrpc virtclient.domainxml(:domain => configuration[:domain])
    end

    def domains_command
        virtclient.hvinfo.each do |r|
            domains = r[:data][:active_domains] << r[:data][:inactive_domains]

            puts "%30s:    %s" % [r[:sender], domains.flatten.sort.join(", ")]
        end

        puts
    end

    def start_command
        printrpc virtclient.create(:domain => configuration[:domain])
    end

    def stop_command
        printrpc virtclient.shutdown(:domain => configuration[:domain])
    end

    def suspend_command
        printrpc virtclient.suspend(:domain => configuration[:domain])
    end

    def resume_command
        printrpc virtclient.resume(:domain => configuration[:domain])
    end

    def destroy_command
        printrpc virtclient.destroy(:domain => configuration[:domain])
    end

    def find_command
        pattern = Regexp.new(configuration[:domain])

        virtclient.hvinfo.each do |r|
            domains = r[:data][:active_domains] << r[:data][:inactive_domains]
            matched = domains.grep pattern

            if matched.size > 0
                puts "%30s:    %s" % [r[:sender], matched.sort.join(", ")]
            end
        end

        puts
    end

    def virtclient
        @client ||= rpcclient("libvirt")
    end

    def main
        cmd = configuration[:command] + "_command"

        if respond_to?(cmd)
            send(cmd)
        else
            raise "Support for #{configuration[:command]} has not yet been implimented"
        end
    end
end