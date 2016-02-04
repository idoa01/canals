require 'canals'
require 'canals/tools/completion'
require 'thor'

module Canals
  module Cli
    class Setup < Thor
      include Thor::Actions

      desc "wizard", "Run the setup wizard"
      def wizard
        say "Welcome to the Canals Setup Wizard!", :green
        check_install_completion
        say "Setup complete. Thanks! :)", :green
      end

      desc "completion", "Setup bash completion"
      def completion
        install_completion
      end

      no_commands do
        def check_install_completion
          if !check(Canals::Tools::Completion.completion_installed?, "Checking if shell completion is installed...")
            yes?('Shell completion not installed. Would you like to install it now? ') && install_completion
          end
        end

        def install_completion
          Canals::Tools::Completion.install_completion
          say "Shell completion installed.", :green
        end

        def check(check_result, message)
          spaces = "  " * (shell.padding + 1)
          say "#{spaces}#{message}#{spaces}#{humanize(check_result)}"
          return check_result
        end

        def humanize(bool)
          bool ? set_color("yes",:green) : set_color("no", :red)
        end
      end

      default_task :wizard
    end
  end
end


