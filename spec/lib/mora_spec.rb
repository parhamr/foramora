require 'spec_helper'

describe Mora do
  describe '[class]' do
    subject { Mora }
  end

  describe '[instance]' do
    subject { Mora.new }
    it 'successfully initializes' do
      expect { subject }.to_not raise_error
    end
  end
end
