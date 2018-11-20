require 'canals/tools/yaml'

module Canals
  CanalOptionError = Class.new StandardError

  class CanalOptions
    BIND_ADDRESS = "127.0.0.1"
    attr_reader :name, :remote_host, :remote_port, :local_port, :env_name, :env, :adhoc, :socks

    # define setters
    [:name, :local_port, :adhoc, :socks].each do |attribute|
      define_method :"#{attribute}=" do |value|
        @args[attribute] = value
        self.instance_variable_set(:"@#{attribute}", value)
      end
    end

    def initialize(args)
      @original_args = validate?(args)
      @args = Marshal.load(Marshal.dump(@original_args))
      @name = @args[:name]
      @remote_host = @args[:remote_host]
      @remote_port = @args[:remote_port]
      @local_port = @args[:local_port]
      @adhoc = @args[:adhoc] || false
      @socks = @args[:socks] || false
      @env_name = @args[:env]
      @env = Canals.repository.environment(@env_name)
    end

    def to_s
      return "CanalOptions<#{@args}>"
    end

    def bind_address
      return @args[:bind_address] if @args[:bind_address]
      return Canals.config[:bind_address] if Canals.config[:bind_address]
      return BIND_ADDRESS
    end

    def hostname
      get_env_var(:hostname)
    end

    def user
      get_env_var(:user)
    end

    def pem
      get_env_var(:pem)
    end

    def proxy
      prxy = ""
      prxy += "-i #{pem} " if pem
      prxy += "#{user}@#{hostname}"
      prxy
    end

    def to_yaml
      Canals::Tools::YAML.to_yaml(@args)
    end

    def to_hash(mode=:basic)
      args_copy = Marshal.load(Marshal.dump(@args))
      args_copy.merge! exploded_options if mode == :full
      args_copy
    end

    def exploded_options
      {bind_address: bind_address, hostname: hostname, user: user, pem: pem, proxy: proxy, adhoc: adhoc, socks: socks}
    end

    private

    def validate?(args)
      vargs = args.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
      raise CanalOptionError.new("Missing option: \"name\" in canal creation") if vargs[:name].nil?
      if vargs[:socks]
        raise CanalOptionError.new("Missing option: \"hostname\" in canal creation") if vargs[:hostname].nil?
        raise CanalOptionError.new("Missing option: \"local_port\" in canal creation") if vargs[:local_port].nil?
      else
        raise CanalOptionError.new("Missing option: \"remote_host\" in canal creation") if vargs[:remote_host].nil?
        raise CanalOptionError.new("Missing option: \"remote_port\" in canal creation") if vargs[:remote_port].nil?
      end

      vargs[:remote_port] = vargs[:remote_port].to_i
      if vargs[:local_port].nil?
        vargs[:local_port] = vargs[:remote_port]
      else
        vargs[:local_port] = vargs[:local_port].to_i
      end
      vargs
    end

    def get_env_var(var)
      return @args[var] if @args[var]
      return @env.send var.to_sym if @env
      nil
    end

  end
end
