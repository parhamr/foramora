require 'spec_helper'

describe Fora do
  
  describe '[class]' do

    subject { Fora }

    its(:foræ) { should be_an Array }
    its(:test_uris) { should be_a Hash }
    its(:platforms) { should be_a Hash }
  end

  describe '[instance]' do

    subject { Fora.new }

  end
end
