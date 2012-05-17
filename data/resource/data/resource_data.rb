module MCollective
  module Data
    class Resource_data<Base
      activate_when { File.exist?("/var/lib/puppet/state/resources.txt") }

      query do |resource|
        resources = File.readlines("/var/lib/puppet/state/resources.txt").map {|l| l.chomp}
        stat = File.stat("/var/lib/puppet/state/resources.txt")

        if resource
          result[:managed] = resources.include?(resource.downcase)
        else
          result[:managed] = false
        end

        result[:count] = resources.size
        result[:age] = Time.now.to_i - stat.mtime.to_i
      end
    end
  end
end


