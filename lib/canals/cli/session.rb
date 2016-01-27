require 'canals'
require 'thor'


module Canals
  module Cli
    class Session < Thor

      desc "show", "Show the current session"
      def show
        if Canals.session.empty?
          puts "Session is currently empty."
          return
        end
        require 'terminal-table'
        require 'canals/core_ext/string'
        columns = ["pid", "name", "socket"]
        rows = Canals.session.map{ |s| columns.map{ |c| s[c.to_sym] } }
        table = Terminal::Table.new :headings => columns.map{|c| c.sub("_"," ").titleize }, :rows => rows
        puts table
      end

      desc "restore", "Restore the connection to tunnels which aren't working"
      def restore
        if Canals.session.empty?
          puts "Session is currently empty."
          return
        end
        Canals.session.each do |sess|
          name = sess[:name]
          if Canals.isalive? name
            puts "Canal #{name.inspect} is running.".green
          else
            puts "Restoring canal #{name.inspect}...".light_red
            Canals.session.del(name)
            Canals.start(name)
          end
        end
        puts
        puts "restore done.".green
      end

      desc "restart", "Restart the current session (closing and starting all connections)"
      def restart
        if Canals.session.empty?
          puts "Session is currently empty."
          return
        end
        Canals.session.each do |sess|
          name = sess[:name]
          Canals.restart(name)
        end
        puts
        puts "restart done.".green
      end

      default_task :show
    end
  end
end


