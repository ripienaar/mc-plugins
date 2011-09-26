class Exim
    include MCollective::RPC

    def initialize
        @exim = rpcclient("eximng")
        @exim.instance_eval { undef :freeze }
        @exim.progress = false

        if File.exist?("serverlist.yaml")
            @exim.discover :hosts => YAML.parse_file("serverlist.yaml")
        else
            raise "A yaml file with server names is needed in serverlist.yaml"
        end
    end

    def mailq
        mailq = []

        @exim.mailq do |r, s|
            begin
                mailq.concat s[:data][:mailq]
            rescue
            end
        end

        return mailq
    end

    def size
        @exim.size
    end

    def rm(msgid)
        @exim.rm(:msgid => msgid)
    end

    def thaw(msgid)
        @exim.thaw(:msgid => msgid)
    end

    def freeze(msgid)
        @exim.freeze(:msgid => msgid)
    end

    def retrymsg(msgid)
        @exim.retrymsg(:msgid => msgid)
    end

    def rmfrozen
        @exim.rmfrozen
    end

    def rmbounces
        @exim.rmbounces
    end

    def exiwhat
        @exim.exiwhat
    end

    def runq(pattern=nil)
        if pattern
            @exim.runq
        else
            @exim.runq(:pattern => pattern)
        end
    end

    def ddl
        @exim.ddl
    end


    def client
        @exim
    end
end
