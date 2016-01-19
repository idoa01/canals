require 'spec_helper'
require 'canals/options'
require 'psych'

describe Canals::CanalOptions do

  context "mandatory fields" do
    let(:name) { "example" }
    let(:remote_host) { "www.example.com" }
    let(:remote_port) { 1234 }
    let(:local_port)  { 4321 }

    it "contains 'name'" do
      args = {"name" => name, "remote_host" => remote_host, "remote_port" => remote_port}
      opt = Canals::CanalOptions.new(args)
      expect(opt.name).to eq name
    end

    it "contains 'remote_host'" do
      args = {"name" => name, "remote_host" => remote_host, "remote_port" => remote_port}
      opt = Canals::CanalOptions.new(args)
      expect(opt.remote_host).to eq remote_host
    end

    it "contains 'remote_port'" do
      args = {"name" => name, "remote_host" => remote_host, "remote_port" => remote_port}
      opt = Canals::CanalOptions.new(args)
      expect(opt.remote_port).to eq remote_port
    end

    it "raises error when 'name' is not availble" do
      args = {"remote_host" => remote_host, "remote_port" => remote_port}
      expect{Canals::CanalOptions.new(args)}.to raise_error(Canals::CanalOptionError)
    end

    it "raises error when 'remote_host' is not availble" do
      args = {"name" => name, "remote_port" => remote_port}
      expect{Canals::CanalOptions.new(args)}.to raise_error(Canals::CanalOptionError)
    end

    it "raises error when 'remote_port' is not availble" do
      args = {"name" => name, "remote_host" => remote_host}
      expect{Canals::CanalOptions.new(args)}.to raise_error(Canals::CanalOptionError)
    end

    it "returns 'remote_port' for 'local_port' if 'local_port' isn't given" do
      args = {"name" => name, "remote_host" => remote_host, "remote_port" => remote_port}
      opt = Canals::CanalOptions.new(args)
      expect(opt.local_port).to eq remote_port
    end

    it "returns 'local_port' if 'local_port' is availble" do
      args = {"name" => name, "remote_host" => remote_host, "remote_port" => remote_port, "local_port" => local_port}
      opt = Canals::CanalOptions.new(args)
      expect(opt.local_port).to eq local_port
    end

    it "transforms remote_port to int if given in string" do
      args = {"name" => name, "remote_host" => remote_host, "remote_port" => '1234'}
      opt = Canals::CanalOptions.new(args)
      expect(opt.remote_port).to eq 1234
      expect(opt.local_port).to eq 1234
    end

    it "transforms local_port to int if given in string" do
      args = {"name" => name, "remote_host" => remote_host, "remote_port" => remote_port, "local_port" => "4321"}
      opt = Canals::CanalOptions.new(args)
      expect(opt.local_port).to eq 4321
    end

    it "dumps remote_port as int" do
      args = {"name" => name, "remote_host" => remote_host, "remote_port" => '1234'}
      yaml = Canals::CanalOptions.new(args).to_yaml
      reparsed = Psych.load(yaml)
      expect(reparsed["remote_port"]).to eq 1234
      expect(reparsed["local_port"]).to eq 1234
    end

    it "dumps local_port as int" do
      args = {"name" => name, "remote_host" => remote_host, "remote_port" => remote_port, "local_port" => "4321"}
      yaml = Canals::CanalOptions.new(args).to_yaml
      reparsed = Psych.load(yaml)
      expect(reparsed["local_port"]).to eq 4321
    end
  end
end

