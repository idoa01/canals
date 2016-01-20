module Canals
  class Canal

    def create_tunnel(tunnel_opts)
      Canals.repository.add tunnel_opts
    end

    def start(tunnel_opts)
      #pid = Process.spawn(tunnel_command(tunnel_opts))
      #puts "started ssh on pid #{pid}"
      if tunnel_opts.instance_of? String
        tunnel_opts = Canals.repository.get(tunnel_opts)
      end
      puts tunnel_command(tunnel_opts)
    end

    private

    def tunnel_command(tunnel_opts)
      "ssh -N -f -L #{tunnel_opts.bind_address}:#{tunnel_opts.local_port}:#{tunnel_opts.remote_host}:#{tunnel_opts.remote_port} #{tunnel_opts.proxy}"
    end

    def proxy(tunnel_opts)
    end

  end
end
