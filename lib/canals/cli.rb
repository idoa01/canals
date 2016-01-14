require 'canals'
require 'thor'

module Canals
  class CLI < Thor

    desc 'create REMOTE_HOST REMOTE_PORT=N', 'create a new tunnel'
    method_option :local_port,
                  :type => :numeric
    def create(remote_host, remote_port)
      puts "remote_host: #{remote_host.inspect}"
      puts "remote_port: #{remote_port.to_i.inspect}"
      puts "options: #{options.inspect}"
    end

  end
end
