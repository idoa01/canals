require 'logger'
require 'canals/canal'

# a gem for managing ssh tunnel connections
module Canals
  extend self

  autoload :Settings, "canals/settings"
  autoload :Repository, "canals/repository"


  attr_accessor :logger

  def settings
    return @settings if defined?(@settings)
    @settings = Settings.new(File.join(Dir.home, '.canals'))
  end

  def repository
    return @repository if defined?(@repository)
    @repository = Repository.new
  end

  def environments
    return @repository.environments if defined?(@repository)
    @repository = Repository.new
    @repository.environments
  end
end

# default logger
Canals.logger = Logger.new(STDERR)
