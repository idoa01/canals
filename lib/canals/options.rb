require 'psych'

module Canals
  class CanalOptionError < StandardError; end

  class CanalOptions
    attr_reader :name, :remote_host, :remote_port, :local_port, :env
    def initialize(args)
      @args = validate?(args)
      @name = @args["name"]
      @remote_host = @args["remote_host"]
      @remote_port = @args["remote_port"]
      @local_port = @args["local_port"]
      @env = Canals.repository.environment(@args['env'])
    end

    def validate?(args)
      vargs = args.dup
      raise CanalOptionError.new("Missing option: \"name\" in canal creation") if args["name"].nil?
      raise CanalOptionError.new("Missing option: \"remote_host\" in canal creation") if args["remote_host"].nil?
      raise CanalOptionError.new("Missing option: \"remote_port\" in canal creation") if args["remote_port"].nil?
      vargs["remote_port"] = vargs["remote_port"].to_i
      if vargs["local_port"].nil?
        vargs["local_port"] = vargs["remote_port"]
      else
        vargs["local_port"] = vargs["local_port"].to_i
      end
      vargs
    end

    def hostname
      get_env_var("hostname")
    end

    def user
      get_env_var("user")
    end

    def pem
      get_env_var("pem")
    end

    def proxy
      "#{user}@#{hostname}"
    end

    def to_yaml
      Psych.dump(@args)
    end

    def to_hash
      @args.dup
    end

    private

    def get_env_var(var)
      return @args[var] if @args[var]
      return @env.send var.to_sym if @env
      nil
    end

  end
end
