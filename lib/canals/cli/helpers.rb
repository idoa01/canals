require 'canals'
require 'canals/version'
require 'canals/tools/completion'

module Canals
  module Cli
    module Helpers

      def tstop(tunnel_opts)
        if tunnel_opts.instance_of? String
          tunnel_opts = tunnel_options(tunnel_opts)
        end
        Canals.stop(tunnel_opts)
        say "Tunnel #{tunnel_opts.name.inspect} stopped."
      end

      def tstart(tunnel_opts)
        if tunnel_opts.instance_of? String
          tunnel_opts = tunnel_options(tunnel_opts)
        end
        pid = Canals.start(tunnel_opts)
        say "Created tunnel #{tunnel_opts.name.inspect} with pid #{pid}. You can access it using '#{tunnel_opts.bind_address}:#{tunnel_opts.local_port}'"
        pid
      rescue Canals::Exception => e
        if tunnel_opts.instance_of? String
          tunnel_opts = tunnel_options(tunnel_opts)
        end
        isalive = Canals.isalive? tunnel_opts
        say "Unable to create tunnel #{tunnel_opts.name.inspect}#{isalive ? ', A tunnel for ' + tunnel_opts.name.inspect + ' Already exists.' : ''}", :red
        0
      end

      def trestart(tunnel_opts)
        if tunnel_opts.instance_of? String
          tunnel_opts = tunnel_options(tunnel_opts)
        end
        tstop(tunnel_opts)
        tstart(tunnel_opts)
      end

      def tunnel_options(name)
        if (Canals.repository.has?(name))
          Canals.repository.get(name)
        elsif (Canals.session.has?(name))
          Canals.session.get_obj(name)
        else
          raise Thor::Error.new "Unable to find tunnel #{name.inspect}."
        end
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
