require 'canals/environment'
require 'psych'

describe Canals::Environment do
  let(:name)  { "blah" }
  let(:hostname)  { "nat.example.com" }
  let(:user)  { "user" }
  let(:pem)  { "/tmp/file.pem" }

  describe "name" do
    it "contains 'name'" do
      args = {"name" => name}
      env = Canals::Environment.new(args)
      expect(env.name).to eq name
    end

    it "raises error when 'name' is not availble" do
      args = {"hostname" => hostname}
      expect{Canals::Environment.new(args)}.to raise_error(Canals::CanalEnvironmentError)
    end
  end

  describe "hostname" do
    it "contains 'hostname'" do
      args = {"name" => name, "hostname" => hostname}
      env = Canals::Environment.new(args)
      expect(env.hostname).to eq hostname
    end
  end

  describe "user" do
    it "contains 'user'" do
      args = {"name" => name, "user" => user}
      env = Canals::Environment.new(args)
      expect(env.user).to eq user
    end
  end

  describe "pem" do
    it "contains 'pem'" do
      args = {"name" => name, "pem" => pem}
      env = Canals::Environment.new(args)
      expect(env.pem).to eq pem
    end
  end

  describe "default" do
    it "returns 'defualt' true if default" do
      args = {"name" => name, "default" => true}
      env = Canals::Environment.new(args)
      expect(env.is_default?).to eq true
    end

    it "returns 'defualt' false if default" do
      args = {"name" => name, "default" => false}
      env = Canals::Environment.new(args)
      expect(env.is_default?).to eq false
    end

    it "returns 'defualt' false if default not availble" do
      args = {"name" => name}
      env = Canals::Environment.new(args)
      expect(env.is_default?).to eq false
    end

    it "default can be changed" do
      args = {"name" => name, "default" => true}
      env = Canals::Environment.new(args)
      expect(env.is_default?).to eq true
      expect(env.to_hash["default"]).to eq true
      env.default = false
      expect(env.is_default?).to eq false
      expect(env.to_hash["default"]).to eq false
    end
  end
end
