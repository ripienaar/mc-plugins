class MCollective::Application::Cap<MCollective::Application
  description "Use discovery for Capistrano host lists"

  usage "mco cap [filters] -- [cap options]"

  def main
    mc = rpcclient("discovery")

    raise "No hosts discovered" if mc.discover.empty?

    ENV["HOSTS"] = mc.discover.join(",")

    exec "cap", *ARGV
  end
end
