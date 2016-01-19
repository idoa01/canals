module Canals
  class Canal
    DEFAULT_OPTS = {hostname: "nat.aws.example.com", user: "ec2-user", bind_address: "localhost"}

    def create_tunnel(tunnel_opts)
      Canals.repository.add tunnel_opts
    end

    private

    def tunnel_command(tunnel_opts)
      #"ssh -N -f -L #{tunnel_opts.bind_address}:#{tunnel_opts.local_port}:#{tunnel_opts.remote_host}:#{tunnel_opts.remote_port} #{tunnel_opts.user}#{tunnel_opts.user ? '@' : ''}#{tunnel_opts.hostname}"
      "ssh -N -f -L #{tunnel_opts.local_port}:#{tunnel_opts.remote_host}:#{tunnel_opts.remote_port}"
    end

  end
end
