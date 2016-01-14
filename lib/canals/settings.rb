require 'psych'

module Canals
  class Settings

    def initialize(root = nil)
      @root = root
      @config = load_config(global_config_file)
    end

    def global_config_file
      file = File.join(Dir.home, '.canals/config')
      Pathname.new(file)
    end

    def load_config(config_file)
      valid_file = config_file && config_file.exist? && !config_file.size.zero?
      Canals.logger.debug "config_file? #{valid_file}"
      return {} if !valid_file
      return Psych.load(valid_file)
    end

  end
end
