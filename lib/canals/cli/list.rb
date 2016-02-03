require 'canals'
require 'canals/options'
require 'canals/environment'
require 'thor'
require 'pry'

module Canals
  module Cli
    class List < Thor

      desc 'environments', 'List the different environments'
      def environments
        envs = Canals.environments.map{ |conf| conf.name }
        puts envs.sort
      end

      desc 'tunnels', 'List the different tunnels'
      def tunnels
        tunnels = Canals.repository.map{ |conf| conf.name }
        puts tunnels.sort
      end

      desc 'commands', 'List all the base level commands'
      def commands(subcommand=nil)
        #binding.pry
        thor_class = Canals::Cli::Application
        if !subcommand.nil?
          thor_class = thor_class.subcommand_classes[subcommand]
          if thor_class.nil?
            return
          end
        end

        cmds = thor_class.all_commands.values.select{ |c| c.class == Thor::Command }.map{ |c| c.name }
        puts cmds.sort
      end

    end
  end
end


