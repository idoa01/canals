require 'logger'

# a gem for managing ssh tunnel connections
module Canals
  extend self

  attr_accessor :logger
end

# default logger
Canals.logger = Logger.new(STDERR)
