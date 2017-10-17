require 'canals'
require 'canals/version'
require 'canals/tools/completion'

module Canals
  module Cli
    module Helpers

      def tstop(name)
        Canals.stop(name)
        say "Tunnel #{name.inspect} stopped."
      end

      def tstart(tunnel_opts)
        if tunnel_opts.instance_of? String
          tunnel_opts = Canals.repository.get(tunnel_opts)
        end
        pid = Canals.start(tunnel_opts)
        say "Created tunnel #{tunnel_opts.name.inspect} with pid #{pid}. You can access it using '#{tunnel_opts.bind_address}:#{tunnel_opts.local_port}'"
        pid
      rescue Canals::Exception => e
        if tunnel_opts.instance_of? String
          tunnel_opts = Canals.repository.get(tunnel_opts)
        end
        isalive = Canals.isalive? tunnel_opts
        say "Unable to create tunnel #{tunnel_opts.name.inspect}#{isalive ? ', A tunnel for ' + tunnel_opts.name.inspect + ' Already exists.' : ''}", :red
        0
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
            say "Bash completion script upgraded, use `source #{Canals::Tools::Completion.cmp_file}` to reload it", :red
          end
        end
      end

      # transform boolean into ✓ / ✗
      def checkmark(bool)
        bool ? "\u2713".encode('utf-8') : "\u2717".encode('utf-8')
      end
    end
  end
end
