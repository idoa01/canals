require 'psych'
require 'pathname'
require 'forwardable'

module Canals
  class Session
    include Enumerable
    extend Forwardable

    def initialize
      @session = load_session(session_file)
    end

    def_delegator :@session, :[]

    def each(&block)
      @session.each(&block)
    end

    def empty?
      @session.empty?
    end

    def add(session, save=true)
      @session.push(session)
      save! if save
    end

    def del(name, save=true)
      @session.delete_if{ |s| s[:name] == name }
      save! if save
    end

    def get(session_id)
      case session_id
      when Numeric
        @session.find{ |s| s[:pid] == session_id }
      when String
        @session.find{ |s| s[:name] == session_id }
      end
    end

    def alive?(session_id)
      sess = get(session_id)
      File.exist?(sess[:socket])
    end

    def save!
      FileUtils.mkdir_p(session_file.dirname)
      File.open(session_file, 'w') do |file|
        file.write(Psych.dump(@session))
      end
    end

    private

    def session_file
      file = File.join(Dir.home, '.canals/session')
      Pathname.new(file)
    end

    def load_session(_session_file)
      valid_file = _session_file && _session_file.exist? && !_session_file.size.zero?
      return [] if !valid_file
      return Psych.load_file(_session_file)
    end

  end
end
