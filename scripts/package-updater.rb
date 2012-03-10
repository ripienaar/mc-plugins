#!/usr/bin/ruby

# A simple script that uses the new batch mode available in
# mcollective 1.3.3 and newer to do package updates:
#
#    pacakge-updater.rb --batch 10
#
# This will give you the chance to clean yum cache everywhere
# and then it will:
#
#  - use the checkupdates action to get a list of available
#    updates on all machines
#  - present you with a menu of available updates
#  - the package you picked will be updated in batches of 10
#    machines at a time
#
# This loops until nothing is left to update
#
# While mco 1.3.2 has batching support there's been some refinements
# that this script relies on, do not use it on older mcollectives
#
# R.I.Pienaar / rip@devco.net / @ripienaar / http://devco.net/

require 'mcollective'

include MCollective::RPC

STDOUT.sync = true
STDERR.sync = true

def err(msg)
  STDERR.puts "EEE> #{msg}"
end

def msg(msg)
  puts ">>>> #{msg}"
end

def ask(msg)
  print "#{msg} (y/n) "

  ans = STDIN.gets.chomp.downcase

  ans == "y"
end

def get_updates_due(agent)
  updates = {}

  agent.reset

  msg "Checking for updates on #{agent.discover.size} servers"

  agent.checkupdates(:batch_size => 0) do |r, s|
    begin
      outdated = [s[:data][:outdated_packages]].compact.flatten

      unless outdated.empty?
        msg "Found %d updates for %s" % [outdated.size, s[:sender]]

        outdated.each do |pkg|
          name = pkg[:package]

          updates[name] ||= []
          updates[name] << s[:sender]
        end
      else
        msg "Found no updates for %s" % [ s[:sender] ]
      end
    rescue => e
      err("Failed to parse data: #{e}: #{r.pretty_inspect}")
    end
  end

  updates
end

def print_list(updates)
  updates.keys.sort.each_with_index do |pkg, idx|
    puts "%3d> %s on %d hosts" % [idx, pkg, updates[pkg].size]
  end

  puts
  puts "  r> Refresh updates list"
  puts "  q> Quit"
end

def update_pkg(updates, selection, agent)
  pkg = updates.keys.sort[selection]

  puts

  msg "Updating %s on %d servers in batches of %d" % [pkg, updates[pkg].size, agent.batch_size]

  agent.discover :hosts => updates[pkg]

  versions = {}

  agent.update(:package => pkg).each_with_index do |resp, i|
    puts if i == 0

    status = resp[:data][:properties]

    if resp[:statuscode] == 0
      if status.include?(:version)
        version = "#{status[:version]}-#{status[:release]}"
      elsif status.include?(:ensure)
        version = status[:ensure].to_s
      end

      versions.include?(version) ? versions[version] += 1 : versions[version] = 1

      printf("%-40s version = %s-%s\n", resp[:sender], status[:name], version)
    else
      printf("%-40s error = %s\n", resp[:sender], resp[:statusmsg])
    end
  end

  puts
  msg "Versions: %s" % [ versions.keys.sort.map {|s| "#{versions[s]} * #{s}" }.join(", ") ]
  puts

  if versions.keys.size == 1
    return pkg
  else
    err "Some updates of #{pkg} failed, got %d versions" % [ versions.keys.size ]
  end
end

@agent = rpcclient("package")

if @agent.batch_size == 0
  exit unless ask("Are you sure you wish to continue without specifying a batch size using --batch?")
end

printrpc(@agent.yum_clean) if ask("Would you like to clear the yum cache everywhere?")

updates_due = get_updates_due(@agent)

until updates_due.empty?
  begin
    print_list(updates_due)

    puts
    print "Pick a package to update:  "

    choice = STDIN.gets.chomp.downcase

    if choice == "r"
      updates_due = get_updates_due(@agent)
      next
    elsif choice == "q"
      exit
    end

    pkg = Integer(choice)
    updates_due.delete(update_pkg(updates_due, pkg, @agent))
  rescue Interrupt
    exit
  rescue SystemExit
    raise
  rescue => e
    err "#{e.class}: #{e}"
    err e.backtrace.pretty_inspect
    retry
  end
end
