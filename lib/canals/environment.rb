require 'psych'

module Canals
  class CanalOptionError < StandardError; end

  class Enviroment
    attr_reader :name, :user, :hostname, :pem
    def initialize(args)
      @args = validate?(args)
      @name = @args["name"]
      @user = @args["user"]
      @hostname = @args["hostname"]
      @pem = @args["pem"]
    end

    def validate?(args)
      vargs = args.dup
      raise CanalOptionError.new("Missing option: \"name\" in environment creation") if args["name"].nil?
      vargs
    end

    def default=(val)
      @args["default"] = !!val
    end

    def is_default?
      !!@args["default"]
    end

    def to_yaml
      Psych.dump(@args)
    end

    def to_hash
      @args.dup
    end

  end
end

