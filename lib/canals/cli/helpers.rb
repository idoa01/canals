require 'canals'

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

    end
  end
end
