require 'canals'
require 'canals/options'
require 'canals/environment'
require 'canals/cli/environment'
require 'canals/cli/session'
require 'canals/cli/setup'
require 'canals/cli/list'
require 'colorize'
require 'thor'

module Canals
  module Cli
    class Application < Thor
      include Thor::Actions

      desc 'create NAME REMOTE_HOST REMOTE_PORT [LOCAL_PORT]', "Create a new tunnel; if LOCAL_PORT isn't supplied, REMOTE_PORT will be used as LOCAL"
      method_option :env,      :type => :string, :desc => "The proxy environment to use"
      method_option :hostname, :type => :string, :desc => "The proxy host we will use to connect through"
      method_option :user,     :type => :string, :desc => "The user for the ssh proxy host"
      def create(name, remote_host, remote_port, local_port=nil)
        opts = {"name" => name, "remote_host" => remote_host, "remote_port" => remote_port, "local_port" => local_port}.merge(options)
        opts = Canals::CanalOptions.new(opts)
        Canals.create_tunnel(opts)
        say "Tunnel #{name.inspect} created.".green
      end

      desc 'start NAME', 'Start tunnel'
      def start(name)
        Canals.start(name)
      end

      desc 'stop NAME', 'Stop tunnel'
      def stop(name)
        Canals.stop(name)
      end

      desc 'restart NAME', 'Restart tunnel'
      def restart(name)
        Canals.restart(name)
      end

      desc "repo", "Show the available tunnels, for given enviroment if given"
      method_option :full, :type => :boolean, :desc => "Show full data on repostitory"
      method_option :env,  :type => :string , :desc => "Show data only on given environment"
      method_option :'sort-by',  :type => :string, :desc => "Sort by this field", :default => "name"
      def repo
        if Canals.repository.empty?
          say "Repository is currently empty."
          return
        end
        require 'terminal-table'
        require 'canals/core_ext/string'
        columns = ["name", "remote_host", "remote_port", "local_port"]
        columns_extra = ["bind_address", "env_name", "user", "hostname"]
        if options[:full]
          columns += columns_extra
        end

        env = options[:env]
        sort_by = options[:'sort-by'].downcase.split.join("_").to_sym
        rows = Canals.repository.select { |conf| env.nil? || conf.env_name == env }
                                .sort   { |a,b| a.send(sort_by) <=> b.send(sort_by) }
                                .map    { |conf| columns.map{ |c| conf.send c.to_sym } }
        table = Terminal::Table.new :headings => columns.map{|c| c.sub("_"," ").titleize }, :rows => rows
        say table
        say "* use --full to show more data".light_white if !options[:full]
      end

      desc "environment SUBCOMMAND", "Environment related command (use 'canal environment help' to find out more)"
      subcommand "environment", Canals::Cli::Environment

      desc "session SUBCOMMAND", "Session related commands (use 'canal session help' to find out more)"
      subcommand "session", Canals::Cli::Session

      desc "setup", "Setup related commands (use 'canal setup help' to find out more)"
      subcommand "setup", Canals::Cli::Setup

      desc "list", "hidden lists for autocompletion", :hide => true
      subcommand "list", Canals::Cli::List

    end
  end
end
