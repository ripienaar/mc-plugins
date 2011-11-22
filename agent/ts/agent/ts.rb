module MCollective
    module Agent
        class Ts<RPC::Agent
            metadata    :name        => "Task Scheduler Agent",
                        :description => "An agent to create and manage jobs for Task Scheduler",
                        :author      => "R.I.Pienaar <rip@devco.net>",
                        :license     => "ASL2",
                        :version     => "0.1",
                        :url         => "http://www.devco.net/",
                        :timeout     => 5

            activate_when { File.executable?("/usr/bin/ts") }

            action "add" do
              validate :command, :shellsafe

              flags = []
              flags << "-n" if request[:no_output]
              flags << "-g" if request[:gzip_output]
              flags << "-d" if request[:depends_on_previous]
              flags << "-L #{request.uniqid}"
              flags << "-B"

              reply[:exitcode] = run("/usr/bin/ts %s %s" % [flags.join(" "), request[:command]], :stdout => :ts_jobid, :chomp => true)

              reply[:ts_jobid] = reply[:ts_jobid].to_i
              reply[:jobid] = request.uniqid

              case reply[:exitcode]
                when 2
                  reply[:msg] = "Could not enqueue job - the queue is full"
                else
                  reply[:msg] = "Command enqueued with ts job id #{reply[:ts_jobid]}"
              end

              reply.fail("Failed to enqueue the command - exit code was %s" % [reply[:exitcode]]) unless reply[:exitcode] == 0
            end

            action "query" do
              validate :jobid, :shellsafe

              get_queue.each do |job|
                if job[:jobid] == request[:jobid]
                  job.keys.each do |k|
                    reply[k] = job[k]
                  end

                  if request[:output] && job[:state] == "finished"
                    reply[:output] = get_job_output(job[:ts_jobid])
                  else
                    reply[:output] = "Not Requested or not Available"
                  end
                end
              end

              unless reply[:jobid]
                reply.fail! "No job found with job id #{request[:jobid]}"
              end

              reply.fail("Command failed to run - error level %s" % [reply[:error_level]]) unless reply[:error_level] == 0
            end

            action "get_queue" do
              reply[:queue] = get_queue
            end

            def get_job_output(ts_jobid)
              output = ""
              run("/usr/bin/ts -c #{ts_jobid}", :stdout => output, :chomp => true)

              output
            end

            def get_queue
              queue = ""
              run("/usr/bin/ts", :stdout => queue, :chomp => true)

              jobs = []

              queue.split("\n").each do |line|
                if line =~ /(\d+)\s+(\w+)\s+.+?\s+(-*\d+)\s+([\.\d]+)\/([\.\d]+)\/([\.\d]+)\s+\[(.+)\](.+)/
                  jobs << {:ts_jobid => $1, :state => $2, :error_level => Integer($3), :run_time => Float($4),
                           :user_time => Float($5), :system_time => Float($6), :jobid => $7, :command => $8}
                elsif line =~ /(\d+)\s+(\w+).+?\s+\[(.+)\](.+)/
                  jobs << {:ts_jobid => $1, :state => $2, :error_level => 0, :run_time => 0,
                           :user_time => 0, :system_time => 0, :jobid => $3, :command => $4}
                end
              end

              return jobs
            end
        end
    end
end
