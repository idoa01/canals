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
        setup_first_environment
        setup_first_tunnel
        check_install_completion
        say "Setup complete. Thanks! :)", :green
      end

      desc "completion", "Setup bash completion"
      def completion
        install_completion
      end

      no_commands do
        def setup_first_environment
          say "We'll start by setting up your first environment", :green
          say "An 'environment' is the server you connect your tunnels through. you can have many environments."
          say "The first environment is the default one used for new connections (but you can always change this default in the future"
          say ""
          return unless yes? "Wait, should we setup your first environment?", :green
          opts = {}
          opts["name"]     = ask "  Name for environment:"
          opts["hostname"] = ask "  Hostname:"
          opts["user"]     = ask "  User:"
          opts["pem"]      = ask "  PEM file:", :path => true
          opts["default"]  = true
          opts.delete_if { |key, value| value.to_s.strip.empty? }
          if opts["name"].nil? || opts["hostname"].nil?
            say "couldn't add first environment, use 'canal environment create ...' to add it manually.", :red
            return
          end
          env = Canals::Environment.new(opts)
          Canals.repository.add_environment(env)
          say "Environment added. To add more environments in the future, use 'canal environment create...'", :green
        end

        def setup_first_tunnel
          return unless yes? "Should we setup a first tunnel?", :green

          opts = {}
          shell.padding += 1
          opts["name"]        = ask "Name for Tunnel:"
          opts["remote_host"] = ask "Remote host:"
          opts["remote_port"] = ask "Remote port:"
          opts["local_port"]  = ask "Local port:", :default =>opts["remote_port"]
          use_env             = !Canals.repository.environment.nil? && yes?("* Use stored environment?", :bold)
          if use_env
            opts["env"]       = ask "Environment:", :default => Canals.repository.environment.name
          else
            opts["hostname"] = ask "Hostname:"
            opts["user"]     = ask "User:"
            opts["pem"]      = ask "PEM file:", :path => true
          end
          opts.delete_if { |key, value| value.to_s.strip.empty? }
          shell.padding -= 1
          opts = Canals::CanalOptions.new(opts)
          Canals.create_tunnel(opts)
          say "Tunnel added. To add more tunnels in the future, use 'canal create...'", :green
        end

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
          bool ? set_color("yes", :green) : set_color("no", :red)
        end
      end

      default_task :wizard
    end
  end
end


