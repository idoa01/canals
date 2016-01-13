module Canals
  class Canal
    DEFAULT_OPTS = {host: "nat.aws.example.com", user: "ec2-user", local_address: "localhost"}

    def tunnel
      pid = Process.spawn(tunnel_command({remote_host: "mysql-db", remote_port: 3306, local_port: 3307}))
      puts "ssh pid: #{pid}"
    end

    private

    def tunnel_command(opts)
      tunnel_opts = DEFAULT_OPTS.merge(opts)
      tunnel_opts[:local_port] = tunnel_opts[:remote_port] if tunnel_opts[:local_port].nil?
      "ssh -N -f -L #{tunnel_opts[:local_address]}:#{tunnel_opts[:local_port]}:#{tunnel_opts[:remote_host]}:#{tunnel_opts[:remote_port]} #{tunnel_opts[:user]}#{tunnel_opts[:user] ? '@' : ''}#{tunnel_opts[:host]}"
    end
  end
end
