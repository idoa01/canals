require 'canals'
require 'canals/options'
require 'canals/environment'
require 'thor'


module Canals
  class CLI < Thor

    desc 'create NAME REMOTE_HOST REMOTE_PORT=N', 'create a new tunnel'
    method_option :env,  :type => :string, :desc => "The proxy environment to use"
    method_option :host, :type => :string, :desc => "The proxy host we will use to connect through"
    method_option :user, :type => :string, :desc => "The user for the ssh proxy host"
    def create(name, remote_host, remote_port, local_port=nil)
      opts = {"name" => name, "remote_host" => remote_host, "remote_port" => remote_port, "local_port" => local_port}.merge(options)
      opts = Canals::CanalOptions.new(opts)
      Canals::Canal.new.create_tunnel(opts)
    end

    desc 'environment NAME HOSTNAME', 'create a new ssh environment'
    method_option :user,    :type => :string,  :desc => "The user for the ssh proxy host"
    method_option :pem,     :type => :string,  :desc => "The PEM file location for this environment"
    method_option :default, :type => :boolean, :desc => "Make this the default enviroment"
    def environment(name, hostname)
      user, host = hostname.split("@")
      if host.nil?
        host = hostname
        user = nil
      end
      opts = {"name" => name, "hostname" => host}.merge(options)
      opts["user"] = user if !user.nil?
      env = Canals::Enviroment.new(opts)
      Canals.repository.add_environment(env)
    end

    desc 'start NAME', 'start tunnel'
    def start(name)
      Canals::Canal.new.start(name)
    end

    desc "repo", "show the available tunnels"
    def repo
      require 'terminal-table'
      rows = Canals.repository.map{ |name, conf| [conf["name"], conf["remote_host"], conf["remote_port"], conf["local_port"]] }
      table = Terminal::Table.new :headings => ['Name', 'Remote Host', 'Remote Port', 'Local Port'], :rows => rows
      puts table
    end

  end
end
