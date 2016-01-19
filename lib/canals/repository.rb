require 'psych'
require 'forwardable'

module Canals
  class Repository
    extend Forwardable

    def initialize(root = nil)
      @root = root
      @repo = load_repository(repo_file)
    end

    def_delegator :@config, :[]

    def add(options, save=true)
      @repo[:tunnels][options.name] = options.to_hash
      save! if save
    end

    def save!
      FileUtils.mkdir_p(repo_file.dirname)
      File.open(repo_file, 'w') do |file|
        file.write(Psych.dump(@repo))
      end
    end

    private

    def repo_file
      file = File.join(Dir.home, '.canals/repository')
      Pathname.new(file)
    end

    def load_repository(repository_file)
      valid_file = repository_file && repository_file.exist? && !repository_file.size.zero?
      Canals.logger.debug "repository_file? #{valid_file}"
      return { tunnels: {} } if !valid_file
      return Psych.load(valid_file)
    end

  end
end

