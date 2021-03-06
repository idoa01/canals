require 'canals'
require 'canals/options'
require 'canals/environment'
require 'canals/cli/environment'
require 'canals/cli/session'
require 'canals/cli/helpers'
require 'canals/cli/setup'
require 'canals/cli/list'
require 'canals/core_ext/shell_colors'
require 'thor'

module Canals
  module Cli
    class Application < Thor
      include Thor::Actions
      include Canals::Cli::Helpers

      def initialize(*args)
        super
        startup_checks
      end

      desc "--version, -v", "prints the canal's version information", :hide => true
      def __print_version
        say "Canals version #{Canals::VERSION}"
      end
      map %w[--version -v] => :__print_version

      desc 'create NAME REMOTE_HOST REMOTE_PORT [LOCAL_PORT]', "Create a new tunnel; if LOCAL_PORT isn't supplied, REMOTE_PORT will be used as LOCAL"
      method_option :env,          :type => :string, :desc => "The proxy environment to use"
      method_option :hostname,     :type => :string, :desc => "The proxy host we will use to connect through"
      method_option :user,         :type => :string, :desc => "The user for the ssh proxy host"
      method_option :bind_address, :type => :string, :desc => "The bind address to connect to"
      def create(name, remote_host, remote_port, local_port=nil)
        opts = {name: name, remote_host: remote_host, remote_port: remote_port, local_port: local_port}.merge(options)
        opts = Canals::CanalOptions.new(opts)
        Canals.create_tunnel(opts)
        say "Tunnel #{name.inspect} created.", :green
      end

      desc 'delete NAME', "Delete an existing tunnel; if tunnel is active, stop it first"
      def delete(name)
        tunnel = Canals.repository.get(name.to_sym)
        if tunnel.nil?
          say "couldn't find tunnel #{name.inspect}. try using 'create' instead", :red
          return
        end
        tstop(name, silent: true)
        Canals.repository.delete(name.to_sym)
        say "Tunnel #{name.inspect} deleted.", :green
      end

      desc 'update NAME', "Update an existing tunnel"
      method_option :remote_host,  :type => :string, :desc => "The remote host of the tunnel"
      method_option :remote_port,  :type => :string, :desc => "The remote port of the tunnel"
      method_option :local_port,   :type => :string, :desc => "The local port to use"
      method_option :env,          :type => :string, :desc => "The proxy environment to use"
      method_option :hostname,     :type => :string, :desc => "The proxy host we will use to connect through"
      method_option :user,         :type => :string, :desc => "The user for the ssh proxy host"
      method_option :bind_address, :type => :string, :desc => "The bind address to connect to"
      def update(name)
        tunnel = Canals.repository.get(name.to_sym)
        if tunnel.nil?
          say "couldn't find tunnel #{name.inspect}. try using 'create' instead", :red
          return
        end
        if options.empty?
          say "you need to specify what to update. use `canal help update` to see a list of optional updates"
          return
        end
        opts = tunnel.to_hash.merge(options)
        opts = Canals::CanalOptions.new(opts)
        Canals.create_tunnel(opts)
        say "Tunnel #{name.inspect} updated.", :green
      end

      desc 'start NAME', 'Start tunnel'
      method_option :local_port,   :type => :numeric, :desc => "The local port to use"
      def start(name)
        tunnel = tunnel_options(name)
        if options["local_port"]
          tunnel.local_port = options["local_port"]
          tunnel.name = "adhoc-#{name}-#{options["local_port"]}"
          tunnel.adhoc = true
        end
        tstart(tunnel)
      end

      desc 'stop NAME', 'Stop tunnel'
      def stop(name)
        tstop(name)
      end

      desc 'restart NAME', 'Restart tunnel'
      def restart(name)
        trestart(name)
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
                                .sort   { |a,b| a.send(sort_by) <=> b.send(sort_by) rescue a.name <=> b.name }
                                .map    { |conf| columns.map{ |c| conf.send c.to_sym } }
        table = Terminal::Table.new :headings => columns.map{|c| c.sub("_"," ").titleize }, :rows => rows
        say table
        say "* use --full to show more data", [:white, :dim] if !options[:full]
      end

      desc "adhoc REMOTE_HOST REMOTE_PORT [LOCAL_PORT]", "Create and run a new tunnel, without keeping it in the repository; if LOCAL_PORT isn't supplied, REMOTE_PORT will be used as LOCAL"
      method_option :name,         :type => :string, :desc => "The name to use for the tunnel, if not supplied a template will be generated"
      method_option :env,          :type => :string, :desc => "The proxy environment to use"
      method_option :hostname,     :type => :string, :desc => "The proxy host we will use to connect through"
      method_option :user,         :type => :string, :desc => "The user for the ssh proxy host"
      method_option :bind_address, :type => :string, :desc => "The bind address to connect to"
      def adhoc(remote_host, remote_port, local_port=nil)
        opts = {"adhoc" => true, "remote_host" => remote_host, "remote_port" => remote_port, "local_port" => local_port}.merge(options)
        opts["name"] ||= "adhoc-#{remote_host}-#{remote_port}"
        opts = Canals::CanalOptions.new(opts)
        tstart(opts)
      end


      desc "socks LOCAL_PORT", "Create and run a socks connection"
      method_option :name,         :type => :string, :desc => "The name to use for the socks tunnel, if not supplied a template will be generated"
      method_option :env,          :type => :string, :desc => "The proxy environment to use"
      method_option :hostname,     :type => :string, :desc => "The proxy host we will use to connect through"
      method_option :user,         :type => :string, :desc => "The user for the ssh socks host"
      method_option :bind_address, :type => :string, :desc => "The bind address to connect to"
      def socks(local_port)
        opts = {"adhoc" => true, "socks" => true, "local_port" => local_port}.merge(options)
        opts["name"] ||= "__SOCKS__"
        opts = Canals::CanalOptions.new(opts)
        opts.name = "SOCKS-adhoc-#{opts.hostname}-#{local_port}" if opts.name == "__SOCKS__"
        tstart(opts)
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
