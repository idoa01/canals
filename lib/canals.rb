require 'logger'

# a gem for managing ssh tunnel connections
module Canals
  extend self

  autoload :Settings, "canals/settings"


  attr_accessor :logger

  def settings
    return @settings if defined?(@settings)
    @settings = Settings.new(File.join(Dir.home, '.canals'))
  end
end

# default logger
Canals.logger = Logger.new(STDERR)
