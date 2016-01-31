require 'spec_helper'
require 'canals/options'
require 'psych'

describe Canals::CanalOptions do

  let(:name) { "example" }
  let(:remote_host) { "www.example.com" }
  let(:remote_port) { 1234 }
  let(:local_port)  { 4321 }
  let(:bind_address)  { "1.2.3.4" }
  let(:hostname)  { "nat.example.com" }
  let(:user)  { "user" }
  let(:pem)  { "/tmp/file.pem" }

  describe "name" do
    it "contains 'name'" do
      args = {"name" => name, "remote_host" => remote_host, "remote_port" => remote_port}
      opt = Canals::CanalOptions.new(args)
      expect(opt.name).to eq name
    end

    it "raises error when 'name' is not availble" do
      args = {"remote_host" => remote_host, "remote_port" => remote_port}
      expect{Canals::CanalOptions.new(args)}.to raise_error(Canals::CanalOptionError)
    end
  end

  describe "remote_host" do
    it "contains 'remote_host'" do
      args = {"name" => name, "remote_host" => remote_host, "remote_port" => remote_port}
      opt = Canals::CanalOptions.new(args)
      expect(opt.remote_host).to eq remote_host
    end

    it "raises error when 'remote_host' is not availble" do
      args = {"name" => name, "remote_port" => remote_port}
      expect{Canals::CanalOptions.new(args)}.to raise_error(Canals::CanalOptionError)
    end
  end

  describe "remote_port" do
    it "contains 'remote_port'" do
      args = {"name" => name, "remote_host" => remote_host, "remote_port" => remote_port}
      opt = Canals::CanalOptions.new(args)
      expect(opt.remote_port).to eq remote_port
    end

    it "raises error when 'remote_port' is not availble" do
      args = {"name" => name, "remote_host" => remote_host}
      expect{Canals::CanalOptions.new(args)}.to raise_error(Canals::CanalOptionError)
    end

    it "transforms remote_port to int if given in string" do
      args = {"name" => name, "remote_host" => remote_host, "remote_port" => '1234'}
      opt = Canals::CanalOptions.new(args)
      expect(opt.remote_port).to eq 1234
      expect(opt.local_port).to eq 1234
    end

  end

  describe "local_port" do
    it "returns 'local_port' if 'local_port' is availble" do
      args = {"name" => name, "remote_host" => remote_host, "remote_port" => remote_port, "local_port" => local_port}
      opt = Canals::CanalOptions.new(args)
      expect(opt.local_port).to eq local_port
    end

    it "returns 'remote_port' for 'local_port' if 'local_port' isn't given" do
      args = {"name" => name, "remote_host" => remote_host, "remote_port" => remote_port}
      opt = Canals::CanalOptions.new(args)
      expect(opt.local_port).to eq remote_port
    end

    it "transforms local_port to int if given in string" do
      args = {"name" => name, "remote_host" => remote_host, "remote_port" => remote_port, "local_port" => "4321"}
      opt = Canals::CanalOptions.new(args)
      expect(opt.local_port).to eq 4321
    end
  end

  describe "bind_address" do
    it "returns 'bind_address' if 'bind_address' is availble" do
      args = {"name" => name, "remote_host" => remote_host, "remote_port" => remote_port, "local_port" => local_port, "bind_address" => bind_address}
      opt = Canals::CanalOptions.new(args)
      expect(opt.bind_address).to eq bind_address
    end

    it "returns 'Canals::CanalOptions::BIND_ADDRESS' for 'bind_address' if 'bind_address' isn't given" do
      args = {"name" => name, "remote_host" => remote_host, "remote_port" => remote_port, "local_port" => local_port}
      opt = Canals::CanalOptions.new(args)
      expect(opt.bind_address).to eq Canals::CanalOptions::BIND_ADDRESS
    end
  end

  describe "environment variables" do
    context "without env" do
      it "returns 'hostname/user/pem' if availble" do
        args = {"name" => name, "remote_host" => remote_host, "remote_port" => remote_port, "hostname" => hostname, "user" => user, "pem" => pem}
        opt = Canals::CanalOptions.new(args)
        expect(opt.hostname).to eq hostname
        expect(opt.user).to eq user
        expect(opt.pem).to eq pem
      end

      it "returns nil under env_name" do
        args = {"name" => name, "remote_host" => remote_host, "remote_port" => remote_port}
        opt = Canals::CanalOptions.new(args)
        expect(opt.env_name).to be nil
      end

      it "constructs proxy value" do
        args = {"name" => name, "remote_host" => remote_host, "remote_port" => remote_port, "hostname" => hostname, "user" => user, "pem" => pem}
        opt = Canals::CanalOptions.new(args)
        expect(opt.proxy).to eq "#{user}@#{hostname}"
      end
    end

    context "with env" do
      let(:env_name) { "env" }

      before(:each) do
        env = double("environment")

        expect(Canals.repository).to receive(:environment).with(env_name).and_return(env)
        allow(env).to receive(:hostname).and_return(hostname)
        allow(env).to receive(:user).and_return(user)
        allow(env).to receive(:pem).and_return(pem)
      end

      it "returns 'hostname/user/pem' from env" do
        args = {"name" => name, "remote_host" => remote_host, "remote_port" => remote_port, "env" => env_name}
        opt = Canals::CanalOptions.new(args)
        expect(opt.hostname).to eq hostname
        expect(opt.user).to eq user
        expect(opt.pem).to eq pem
      end

      it "returns environment name under env_name" do
        args = {"name" => name, "remote_host" => remote_host, "remote_port" => remote_port, "env" => env_name}
        opt = Canals::CanalOptions.new(args)
        expect(opt.env_name).to eq env_name
      end

      it "constructs proxy value" do
        args = {"name" => name, "remote_host" => remote_host, "remote_port" => remote_port, "env" => env_name}
        opt = Canals::CanalOptions.new(args)
        expect(opt.proxy).to eq"#{user}@#{hostname}"
      end

      it "returns allows overshadowing of env" do
        overshadow_hostname = "*hostname*"
        overshadow_user = "*user*"
        overshadow_pem = "/tmp/overshadow.pem"

        args = {"name" => name, "remote_host" => remote_host, "remote_port" => remote_port, "env" => env_name, "hostname" => overshadow_hostname, "user" => overshadow_user, "pem" => overshadow_pem}
        opt = Canals::CanalOptions.new(args)
        expect(opt.hostname).to eq overshadow_hostname
        expect(opt.user).to eq overshadow_user
        expect(opt.pem).to eq overshadow_pem
        expect(opt.env_name).to eq env_name
      end

      it "constructs proxy value with overshadowing" do
        overshadow_hostname = "*hostname*"
        args = {"name" => name, "remote_host" => remote_host, "remote_port" => remote_port, "env" => env_name, "hostname" => overshadow_hostname}
        opt = Canals::CanalOptions.new(args)
        expect(opt.proxy).to eq "#{user}@#{overshadow_hostname}"
      end
    end
  end


  describe "to_yaml" do
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

