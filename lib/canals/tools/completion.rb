require 'fileutils'
require 'canals'
require 'canals/tools/assets'

module Canals
  module Tools
    module Completion
      include FileUtils
      extend self

      def config_path
        File.expand_path(".canals", ENV['HOME'])
      end

      def cmp_file
        File.expand_path('canals.sh', config_path)
      end

      def install_completion
        update_completion
        source = "source " << cmp_file

        rcfile = File.expand_path('.bashrc', ENV['HOME'])
        return false if File.read(rcfile).include? source
        File.open(rcfile, 'a') { |f| f.puts("", "# added by canals gem", "[ -f #{cmp_file} ] && #{source}") }
        true
      end

      def update_completion
        mkdir_p(config_path)
        cp(Assets['canals.sh'], cmp_file)
        update_config
      end

      def update_config
        Canals.config[:completion_version] = Canals::VERSION
        Canals.config.save!
      end

      def completion_installed?
        source = "source " << cmp_file
        rcfile = File.expand_path('.bashrc', ENV['HOME'])
        return false unless File.read(rcfile).include? source
        true
      end
    end
  end
end

