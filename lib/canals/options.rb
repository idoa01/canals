require 'psych'

module Canals
  class CanalOptionError < StandardError; end

  class CanalOptions
    attr_reader :remote_host, :remote_port, :local_port
    def initialize(args)
      @args = validate?(args)
      @remote_host = @args["remote_host"]
      @remote_port = @args["remote_port"]
      @local_port = @args["local_port"]
    end

    def validate?(args)
      vargs = args.dup
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

    def to_yaml
      Psych.dump(@args)
    end

  end
end
