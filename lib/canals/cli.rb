require 'canals'
require 'canals/options'
require 'thor'


module Canals
  class CLI < Thor

    desc 'create REMOTE_HOST REMOTE_PORT=N', 'create a new tunnel'
    method_option :host, :type => :string, :desc => "The proxy host we will use to connect through"
    method_option :user, :type => :string, :desc => "The user for the ssh proxy host"
    def create(remote_host, remote_port, local_port=nil)
      #local_port = remote_port if local_port.nil?
      #remote_port = remote_port.to_i
      #local_port = local_port.to_i

      puts "remote_host: #{remote_host.inspect}"
      puts "remote_port: #{remote_port.inspect}"
      puts "local_port: #{local_port.inspect}"
      puts "options: #{options.inspect}"


      opts = {"remote_host" => remote_host, "remote_port" => remote_port, "local_port" => local_port}.merge(options)
      opts = Canals::CanalOptions.new(opts)
      Canals::Canal.new.create_tunnel(opts)
    end

  end
end
