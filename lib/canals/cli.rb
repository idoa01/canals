require 'canals'
require 'canals/options'
require 'canals/environment'
require 'canals/cli/environment'
require 'thor'

module Canals
  module Cli
    class Application < Thor

      desc 'create NAME REMOTE_HOST REMOTE_PORT=N', 'create a new tunnel'
      method_option :env,      :type => :string, :desc => "The proxy environment to use"
      method_option :hostname, :type => :string, :desc => "The proxy host we will use to connect through"
      method_option :user,     :type => :string, :desc => "The user for the ssh proxy host"
      def create(name, remote_host, remote_port, local_port=nil)
        opts = {"name" => name, "remote_host" => remote_host, "remote_port" => remote_port, "local_port" => local_port}.merge(options)
        opts = Canals::CanalOptions.new(opts)
        Canals::Canal.new.create_tunnel(opts)
      end

      desc "environment", "enviroment related commands"
      subcommand "environment", Canals::Cli::Environment

      desc 'start NAME', 'start tunnel'
      def start(name)
        Canals::Canal.new.start(name)
      end

      desc "repo", "show the available tunnels"
      method_option :full, :type => :boolean, :desc => "Show full data on repostitory"
      def repo
        require 'terminal-table'
        require 'canals/core_ext/string'
        columns = ["name", "remote_host", "remote_port", "local_port"]
        columns_extra = ["bind_address", "env_name", "user", "hostname"]
        if options[:full]
          columns += columns_extra
        end

        rows = Canals.repository.map{ |conf| columns.map{ |c| conf.send c.to_sym } }
        table = Terminal::Table.new :headings => columns.map{|c| c.sub("_"," ").titleize }, :rows => rows
        puts table
      end

    end
  end
end
