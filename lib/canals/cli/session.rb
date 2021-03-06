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
        columns = ["up", "pid", "name", "local_port", "socket"]
        rows = Canals.session.sort{ |a,b| a[:name] <=> b[:name] }
                             .map { |s| columns.map{ |c| session_col_val(s, c) } }
        table = Terminal::Table.new :headings => columns.map{|c| session_col_title(c) }, :rows => rows
        table.align_column(3, :right)
        say table
      end

      desc "restore", "Restore the connection to tunnels which aren't working"
      def restore
        on_all_canals_in_session(:restore) do |canal|
          if Canals.isalive? canal
            say "Canal #{canal.name.inspect} is running."
          else
            Canals.session.del(canal.name)
            tstart(canal)
          end
        end
      end

      desc "restart", "Restart the current session (closing and starting all connections)"
      def restart
        on_all_canals_in_session(:restart) do |canal|
          trestart(canal)
        end
      end

      desc "stop", "Stop the current session (stops and removes from session)"
      def stop
        on_all_canals_in_session(:stop) do |canal|
          tstop(canal)
        end
      end

      desc "suspend", "Suspend the current session (stops and doesn't remove from session)"
      def suspend
        on_all_canals_in_session(:suspend) do |canal|
          tstop(canal, remove_from_session: false)
        end
      end

      no_commands do
        def on_all_canals_in_session(command, &block)
          return if session_empty?
          Canals.session.each_obj do |canal|
            say "#{command.to_s.capitalize} canal #{canal.name.inspect}:", :green
            block.call(canal)
          end
          say
          say "#{command} done.", :green
        end

        def session_color(session)
          if session_alive(session)
            :white
          else
            [:dark_gray, :dim]
          end
        end

        def session_alive(session)
          @alive ||= {}
          pid = session[:pid]
          @alive[pid] ||= Canals.session.alive? pid
        end

        def session_col_title(col)
          case col
          when "pid"
            "PID"
          else
            col.sub("_", " ").titleize
          end
        end

        def session_col_val(session, key)
          c = session_color(session)
          val = case key
                when "local_port"
                  if session[key.to_sym]
                    session[key.to_sym]
                  else
                    entry = Canals.repository.get(session[:name])
                    entry.local_port if entry
                  end
                when "up"
                  checkmark(session_alive(session))
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


