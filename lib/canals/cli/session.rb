require 'canals'
require 'canals/cli/helpers'
require 'canals/core_ext/shell_colors'
require 'thor'


module Canals
  module Cli
    class Session < Thor
      include Thor::Actions
      include Canals::Cli::Helpers

      desc "show", "Show the current session"
      def show
        return if session_empty?
        require 'terminal-table'
        require 'canals/core_ext/string'
        columns = ["pid", "name", "local_port", "socket"]
        rows = Canals.session.map{ |s| columns.map{ |c| get_session_col_val(s, c) } }
        table = Terminal::Table.new :headings => columns.map{|c| c.sub("_"," ").titleize }, :rows => rows
        table.align_column(2, :right)
        say table
      end

      desc "restore", "Restore the connection to tunnels which aren't working"
      def restore
        on_all_canals_in_session(:restore) do |name|
          if Canals.isalive? name
            say "Canal #{name.inspect} is running."
          else
            Canals.session.del(name)
            tstart(name)
          end
        end
      end

      desc "restart", "Restart the current session (closing and starting all connections)"
      def restart
        on_all_canals_in_session(:restart) do |name|
          trestart(name)
        end
      end

      desc "stop", "Stop the current session"
      def stop
        on_all_canals_in_session(:stop) do |name|
          tstop(name)
        end
      end

      no_commands do
        def on_all_canals_in_session(command, &block)
          return if session_empty?
          Canals.session.map{|s| s[:name]}.each do |name|
            say "#{command.to_s.capitalize} canal #{name.inspect}:", :green
            block.call(name)
          end
          say
          say "#{command} done.", :green
        end

        def session_color(session)
          pid = session[:pid]
          @colors ||= {}
          return @colors[pid] if @colors[pid]
          alive = Canals.session.alive? pid
          if alive
            @colors[pid] = :white
          else
            @colors[pid] = [:dark_gray, :dim]
          end
        end

        def get_session_col_val(session, key)
          c = session_color(session)
          val = case key
          when "local_port"
            entry = Canals.repository.get(session[:name])
            entry.local_port if entry
          else
            session[key.to_sym]
          end
          set_color(val, *c)
        end

        def session_empty?
          if Canals.session.empty?
            say "Canal session is currently empty."
            true
          else
            false
          end
        end
      end

      default_task :show
    end
  end
end


