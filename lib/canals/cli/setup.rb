require 'canals'
require 'canals/tools/completion'
require 'colorize'
require 'thor'

module Canals
  module Cli
    class Setup < Thor
      include Thor::Actions

      desc "wizard", "Run the setup wizard"
      def wizard
        say "Welcome to the Canals Setup Wizard!".green
        install_completion
        say "Setup complete. Thanks! :)".green
      end

      no_commands do
        def install_completion
          say "Checking if shell completion is installed... "
          if Canals::Tools::Completion.completion_installed?
            say "yes".green  and return
          else
            say "no".red
          end
          install = yes?('Shell completion not installed. Would you like to install it now? ')
          if install
            Canals::Tools::Completion.install_completion
            puts "Shell completion installed.".green
          end
        end
      end

      default_task :wizard
    end
  end
end


