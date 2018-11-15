require 'pathname'
require 'forwardable'
require 'canals/tools/yaml'

module Canals
  class Session
    include Enumerable
    extend Forwardable

    BASIC_FIELDS = [:name, :pid, :socket]

    def initialize
      @session = load_session(session_file)
    end

    def_delegator :@session, :[]

    def each(&block)
      @session.each(&block)
    end

    def each_obj(&block)
      @session.map{|sess| CanalOptions.new(fill_from_repository(sess))}.each(&block)
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
      sess = nil
      case session_id
      when Numeric
        sess = @session.find{ |s| s[:pid] == session_id }
      when String
        sess = @session.find{ |s| s[:name] == session_id }
      end
      fill_from_repository(sess) if sess
    end

    def get_obj(session_id)
      sess = get(session_id)
      return nil if sess.nil?
      CanalOptions.new(sess)
    end

    def has?(session_id)
      get(session_id) != nil
    end

    def alive?(session_id)
      sess = get(session_id)
      File.exist?(sess[:socket])
    end

    def save!
      FileUtils.mkdir_p(session_file.dirname)
      Canals::Tools::YAML.dump_file(session_file, @session)
    end

    private

    def session_file
      file = File.join(Dir.home, '.canals/session')
      Pathname.new(file)
    end

    def load_session(_session_file)
      valid_file = _session_file && _session_file.exist? && !_session_file.size.zero?
      return [] if !valid_file
      Canals::Tools::YAML.load_file(_session_file)
    end

    def basic?(sess)
      (sess.keys - BASIC_FIELDS).empty?
    end

    def fill_from_repository(sess)
      if (basic?(sess) && Canals.repository.has?(sess[:name]))
        Canals.repository.get(sess[:name]).to_hash.merge(sess)
      else
        sess
      end
    end

  end
end
