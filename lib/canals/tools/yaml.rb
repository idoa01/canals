require 'psych'

module Canals
  module Tools
    module YAML

      def self.load(content)
        Psych.load(content, symbolize_names: true)
      end

      def self.load_file(filename)
        File.open(filename, 'r:bom|utf-8') { |f|
          Psych.load(f, filename, fallback: false, symbolize_names: true)
        }
      end

      def self.dump_file(filename, content)
        File.open(filename, 'w') do |f|
          f.write(self.to_yaml(content))
        end
      end

      def self.to_yaml(content)
        Psych.dump(content)
      end
    end
  end
end
