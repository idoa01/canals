require 'pathname'
require 'fileutils'
require 'forwardable'
require 'canals/environment'
require 'canals/tools/yaml'

module Canals
  class Repository
    include Enumerable
    extend Forwardable

    ENVIRONMENTS = :environments
    TUNNELS = :tunnels

    def initialize(root = nil)
      @root = root
      @repo = load_repository(repo_file)
    end

    def_delegator :@repo, :[]

    def each(&block)
      @repo[TUNNELS].map{ |n, r| Canals::CanalOptions.new(r) }.each(&block)
    end

    def empty?
      @repo[TUNNELS].empty?
    end

    def add(options, save=true)
      @repo[TUNNELS][options.name.to_sym] = options.to_hash
      if options.env_name.nil? && !options.env.nil? && options.env.is_default?
        @repo[TUNNELS][options.name.to_sym][:env] = options.env.name
      end
      save! if save
    end

    def delete(name, save=true)
      @repo[TUNNELS].delete(name)
      save! if save
    end

    def get(name)
      name = name.to_sym
      return nil if !@repo[:tunnels].has_key? name
      CanalOptions.new(@repo[:tunnels][name])
    end

    def has?(name)
      return @repo[:tunnels].has_key? name.to_sym
    end

    def add_environment(environment, save=true)
      if environment.is_default?
        @repo[ENVIRONMENTS].each { |name, env| env.delete(:default) }
      end
      if @repo[ENVIRONMENTS].empty?
        environment.default = true
      end
      @repo[ENVIRONMENTS][environment.name.to_sym] = environment.to_hash
      save! if save
    end

    def save!
      FileUtils.mkdir_p(repo_file.dirname)
      Canals::Tools::YAML.dump_file(repo_file, @repo)
    end

    def environment(name=nil)
      if name.nil?
        args = @repo[ENVIRONMENTS].select{ |n,e| e[:default] }.values[0]
      else
        args = @repo[ENVIRONMENTS][name.to_sym]
      end
      Canals::Environment.new(args) if !args.nil?
    end

    def environments
      @repo[ENVIRONMENTS].map { |n, e| Canals::Environment.new(e) }
    end

    private

    def repo_file
      file = File.join(Dir.home, '.canals/repository')
      Pathname.new(file)
    end

    def load_repository(repository_file)
      valid_file = repository_file && repository_file.exist? && !repository_file.size.zero?
      return { ENVIRONMENTS => {}, TUNNELS => {} } if !valid_file
      return Canals::Tools::YAML.load_file(repository_file)
    end

  end
end

