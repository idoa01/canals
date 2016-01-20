require 'psych'
require 'forwardable'
require 'canals/environment'

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
      @repo[TUNNELS].each(&block)
    end

    def add(options, save=true)
      @repo[TUNNELS][options.name] = options.to_hash
      save! if save
    end

    def get(name)
      CanalOptions.new(@repo[:tunnels][name])
    end

    def add_environment(environment, save=true)
      if environment.is_default?
        @repo[ENVIRONMENTS].each { |name, env| env.delete("default") }
      end
      if @repo[ENVIRONMENTS].empty?
        environment.default = true
      end
      @repo[ENVIRONMENTS][environment.name] = environment.to_hash
      save! if save
    end

    def save!
      FileUtils.mkdir_p(repo_file.dirname)
      File.open(repo_file, 'w') do |file|
        file.write(Psych.dump(@repo))
      end
    end

    def environment(name)
      if name.nil?
        args = @repo[ENVIRONMENTS].select{ |n,e| e["default"] }.values[0]
      else
        args = @repo[ENVIRONMENTS][name]
      end
      Canals::Environment.new(args) if !args.nil?
    end

    private

    def repo_file
      file = File.join(Dir.home, '.canals/repository')
      Pathname.new(file)
    end

    def load_repository(repository_file)
      valid_file = repository_file && repository_file.exist? && !repository_file.size.zero?
      return { ENVIRONMENTS => {}, TUNNELS => {} } if !valid_file
      return Psych.load_file(repository_file)
    end

  end
end

