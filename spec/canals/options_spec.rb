require 'canals/options'
require 'canals/tools/yaml'

describe Canals::CanalOptions do

  let(:name) { "example" }
  let(:remote_host) { "www.example.com" }
  let(:remote_port) { 1234 }
  let(:local_port)  { 4321 }
  let(:bind_address)  { "1.2.3.4" }
  let(:global_bind_address)  { "4.3.2.1" }
  let(:hostname)  { "nat.example.com" }
  let(:user)  { "user" }
  let(:pem)  { "/tmp/file.pem" }
  let(:adhoc)  { true }
  let(:socks)  { true }

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

  describe "adhoc" do
    it "returns 'adhoc' if 'adhoc' is availble" do
      args = {"name" => name, "remote_host" => remote_host, "remote_port" => remote_port, "adhoc" => adhoc}
      opt = Canals::CanalOptions.new(args)
      expect(opt.adhoc).to eq adhoc
    end

    it "returns 'false' for 'adhoc' if 'adhoc' isn't given" do
      args = {"name" => name, "remote_host" => remote_host, "remote_port" => remote_port}
      opt = Canals::CanalOptions.new(args)
      expect(opt.adhoc).to eq false
    end
  end

  describe "socks" do
    it "returns 'socks' if 'socks' is availble" do
      args = {"name" => name, "remote_host" => remote_host, "remote_port" => remote_port, "local_port" => local_port, "hostname" => hostname, "socks" => socks}
      opt = Canals::CanalOptions.new(args)
      expect(opt.socks).to eq socks
    end

    it "returns 'false' for 'socks' if 'socks' isn't given" do
      args = {"name" => name, "remote_host" => remote_host, "remote_port" => remote_port, "local_port" => local_port, "hostname" => hostname}
      opt = Canals::CanalOptions.new(args)
      expect(opt.socks).to eq false
    end

    it "raises error when 'socks' is true and 'local_port' is not availble" do
      args = {"name" => name, "hostname" => hostname, "socks" => socks}
      expect{Canals::CanalOptions.new(args)}.to raise_error(Canals::CanalOptionError)
    end
  end

  describe "bind_address" do
    it "returns 'bind_address' if 'bind_address' is availble" do
      allow(Canals.config).to receive(:[]).with(:bind_address).and_return(global_bind_address)
      args = {"name" => name, "remote_host" => remote_host, "remote_port"=> remote_port, "local_port" => local_port, "bind_address" => bind_address}
      opt = Canals::CanalOptions.new(args)
      expect(opt.bind_address).to eq bind_address
    end

    it "returns 'Canals::CanalOptions::BIND_ADDRESS' for 'bind_address' if 'bind_address' isn't given and no global bind_address" do
      allow(Canals.config).to receive(:[]).with(:bind_address).and_return(nil)
      args = {"name" => name, "remote_host" => remote_host, "remote_port" => remote_port, "local_port" => local_port}
      opt = Canals::CanalOptions.new(args)
      expect(opt.bind_address).to eq Canals::CanalOptions::BIND_ADDRESS
    end

    it "returns 'Canals.config[:bind_address]' for 'bind_address' if 'bind_address' isn't given and global bind_address" do
      allow(Canals.config).to receive(:[]).with(:bind_address).and_return(global_bind_address)
      args = {"name" => name, "remote_host" => remote_host, "remote_port" => remote_port, "local_port" => local_port}
      opt = Canals::CanalOptions.new(args)
      expect(opt.bind_address).to eq global_bind_address
    end
  end

  describe "environment variables" do
    context "without env" do

      before(:each) do
        expect(Canals.repository).to receive(:environment).and_return(nil)
      end

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
        expect(opt.proxy).to eq "-i #{pem} #{user}@#{hostname}"
      end

      it "constructs proxy value, no pem" do
        args = {"name" => name, "remote_host" => remote_host, "remote_port" => remote_port, "hostname" => hostname, "user" => user}
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
        expect(opt.proxy).to eq "-i #{pem} #{user}@#{hostname}"
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
        expect(opt.proxy).to eq "-i #{pem} #{user}@#{overshadow_hostname}"
      end
    end
  end

  describe "to_yaml" do
    it "dumps remote_port as int" do
      args = {"name" => name, "remote_host" => remote_host, "remote_port" => '1234'}
      yaml = Canals::CanalOptions.new(args).to_yaml
      reparsed = Canals::Tools::YAML.load(yaml)
      expect(reparsed[:remote_port]).to eq 1234
      expect(reparsed[:local_port]).to eq 1234
    end

    it "dumps local_port as int" do
      args = {"name" => name, "remote_host" => remote_host, "remote_port" => remote_port, "local_port" => "4321"}
      yaml = Canals::CanalOptions.new(args).to_yaml
      reparsed = Canals::Tools::YAML.load(yaml)
      expect(reparsed[:local_port]).to eq 4321
    end
  end

  describe "to_hash" do
    it "dumps remote_port as int" do
      args = {"name" => name, "remote_host" => remote_host, "remote_port" => '1234'}
      reparsed = Canals::CanalOptions.new(args).to_hash
      expect(reparsed[:remote_port]).to eq 1234
      expect(reparsed[:local_port]).to eq 1234
    end

    it "dumps local_port as int" do
      args = {"name" => name, "remote_host" => remote_host, "remote_port" => remote_port, "local_port" => "4321"}
      reparsed = Canals::CanalOptions.new(args).to_hash
      expect(reparsed[:local_port]).to eq 4321
    end

    it "turns keys into symbols" do
      args = {"name" => name, "remote_host" => remote_host, "remote_port" => remote_port, "local_port" => "4321"}
      reparsed = Canals::CanalOptions.new(args).to_hash
      expect(reparsed.keys).to all be_an(Symbol)
    end

    it "doesn't add function output when not passed with a 'explode' param" do
      args = {"name" => name, "remote_host" => remote_host, "remote_port" => remote_port, "local_port" => "4321"}
      reparsed = Canals::CanalOptions.new(args).to_hash
      expect(reparsed[:bind_address]).to eq nil
    end

    it "doesn't add function output when passed with 'basic'" do
      args = {"name" => name, "remote_host" => remote_host, "remote_port" => remote_port, "local_port" => "4321"}
      reparsed = Canals::CanalOptions.new(args).to_hash :basic
      expect(reparsed[:bind_address]).to eq nil
    end

    it "adds function output when passed with 'full'" do
      allow(Canals.config).to receive(:[]).with(:bind_address).and_return(global_bind_address)
      args = {"name" => name, "remote_host" => remote_host, "remote_port" => remote_port, "local_port" => "4321"}
      reparsed = Canals::CanalOptions.new(args).to_hash :full
      expect(reparsed[:bind_address]).to eq global_bind_address
    end
  end
end
