require 'psych'

module Canals
  class CanalEnvironmentError < StandardError; end

  class Environment
    attr_reader :name, :user, :hostname, :pem
    def initialize(args)
      @args = validate?(args)
      @name = @args[:name]
      @user = @args[:user]
      @hostname = @args[:hostname]
      @pem = @args[:pem]
    end

    def validate?(args)
      vargs = args.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
      raise CanalEnvironmentError.new("Missing option: \"name\" in environment creation") if vargs[:name].nil?
      vargs
    end

    def default=(val)
      @args[:default] = !!val
    end

    def is_default?
      !!@args[:default]
    end

    def to_yaml
      Psych.dump(@args)
    end

    def to_hash
      Marshal.load(Marshal.dump(@args))
    end

  end
end

