require 'open3'

module Canals
  class << self

    def create_tunnel(tunnel_opts)
      Canals.repository.add tunnel_opts
    end

    def start(tunnel_opts)
      if tunnel_opts.instance_of? String
        tunnel_opts = Canals.repository.get(tunnel_opts)
      end
      tunnel_start(tunnel_opts)
      pid = tunnel_pid(tunnel_opts)
      Canals.session.add({name: tunnel_opts.name, pid: pid, socket: socket_file(tunnel_opts)})
      pid.to_i
    end

    def stop(tunnel_opts)
      if tunnel_opts.instance_of? String
        tunnel_opts = Canals.repository.get(tunnel_opts)
      end
      tunnel_close(tunnel_opts)
      Canals.session.del(tunnel_opts.name)
    end

    def restart(tunnel_opts)
      stop(tunnel_opts)
      start(tunnel_opts)
    end

    def isalive?(tunnel_opts)
      if tunnel_opts.instance_of? String
        tunnel_opts = Canals.repository.get(tunnel_opts)
      end
      !!tunnel_pid(tunnel_opts)
    end

    private

    def socket_file(tunnel_opts)
      "/tmp/canals/canal.#{tunnel_opts.name}.sock"
    end

    def tunnel_start(tunnel_opts)
      FileUtils.mkdir_p("/tmp/canals")
      system("ssh -M -S #{socket_file(tunnel_opts)} -fnNT -L #{tunnel_opts.bind_address}:#{tunnel_opts.local_port}:#{tunnel_opts.remote_host}:#{tunnel_opts.remote_port} #{tunnel_opts.proxy}")
    end

    def tunnel_check(tunnel_opts)
      cmd = "ssh -S #{socket_file(tunnel_opts)} -O check #{tunnel_opts.proxy}"
      Open3.capture2e(cmd)
    end

    def tunnel_close(tunnel_opts)
      cmd = "ssh -S #{socket_file(tunnel_opts)} -O exit #{tunnel_opts.proxy}"
      Open3.capture2e(cmd)
    end

    def tunnel_pid(tunnel_opts)
      stdout, _ = tunnel_check(tunnel_opts)
      m = /\(pid=(.*)\)/.match(stdout)
      m[1].to_i if m
    end

  end
end
