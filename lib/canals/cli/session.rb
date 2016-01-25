require 'canals'
require 'thor'


module Canals
  module Cli
    class Session < Thor

      desc "show", "show the current session"
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

      default_task :show
    end
  end
end


