require 'spec_helper'
require 'canals/settings'

describe Canals::Settings do
  subject(:settings) { described_class.new }

  describe "#[]" do
    context "when not set" do
      context "when default value present"
        it "retrieves value" do
          expect(settings[:retry]).to be 3
        end
    end
  end
end
