require 'pathname'
require 'forwardable'
require 'canals/tools/yaml'

module Canals
  class Config
    extend Forwardable

    def initialize(root = nil)
      @root = root
      @config = load_config(global_config_file)
    end

    def_delegators :@config, :[], :[]=

    def load_config(config_file)
      valid_file = config_file && config_file.exist? && !config_file.size.zero?
      return {} if !valid_file
      return Canals::Tools::YAML.load_file(config_file)
    end

    def save!
      FileUtils.mkdir_p(global_config_file.dirname)
      Canals::Tools::YAML.dump_file(global_config_file, @config)
    end

    private

    def global_config_file
      file = File.join(Dir.home, '.canals/config')
      Pathname.new(file)
    end

  end
end
