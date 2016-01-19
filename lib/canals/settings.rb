require 'psych'
require 'forwardable'

module Canals
  class Settings
    extend Forwardable

    def initialize(root = nil)
      @root = root
      @config = load_config(global_config_file)
    end

    def_delegator :@config, :[]

    def global_config_file
      file = File.join(Dir.home, '.canals/config')
      Pathname.new(file)
    end

    def load_config(config_file)
      valid_file = config_file && config_file.exist? && !config_file.size.zero?
      return {} if !valid_file
      return Psych.load_file(config_file)
    end

  end
end
