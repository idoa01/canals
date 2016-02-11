require 'canals'
require 'canals/tools/completion'

module Canals
  module Cli
    module Helpers

      def tstop(name)
        Canals.stop(name)
        say "Tunnel #{name.inspect} stopped."
      end

      def tstart(name)
        pid = Canals.start(name)
        say "Created tunnel #{name.inspect} with pid #{pid}"
        pid
      end

      def trestart(name)
        tstop(name)
        tstart(name)
      end

      def startup_checks
        check_completion
      end

      def check_completion
        if Canals.config[:completion_version]
          if Canals.config[:completion_version] != Canals::VERSION
            Canals::Tools::Completion.update_completion
            say "bash completion script upgraded, use `source #{Canals::Tools::Completion.cmp_file}` to reload it", :red
          end
        end
      end
    end
  end
end
