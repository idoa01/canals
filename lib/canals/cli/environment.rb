require 'canals'
require 'canals/options'
require 'canals/environment'
require 'thor'


module Canals
  module Cli
    class Environment < Thor

      desc 'create NAME HOSTNAME', 'Create a new ssh environment'
      method_option :user,    :type => :string,  :desc => "The user for the ssh proxy host"
      method_option :pem,     :type => :string,  :desc => "The PEM file location for this environment"
      method_option :default, :type => :boolean, :desc => "Make this the default enviroment"
      def create(name, hostname)
        user, host = hostname.split("@")
        if host.nil?
          host = hostname
          user = nil
        end
        opts = {"name" => name, "hostname" => host}.merge(options)
        opts["user"] = user if !user.nil?
        env = Canals::Environment.new(opts)
        Canals.repository.add_environment(env)
      end

      desc "show [ENV]", "Show the available tunnels"
      def show(env=nil)
        if Canals.environments.empty?
          puts "No environments currently defined."
          return
        end
        require 'terminal-table'
        rows = Canals.environments.select{ |e| env.nil? || e.name == env}.map{ |e| [e.name, e.user, e.hostname, e.pem] }
        table = Terminal::Table.new :headings => ['Name', 'User', 'Hostname', 'PEM'], :rows => rows
        puts table
      end

      default_task :show
    end
  end
end

