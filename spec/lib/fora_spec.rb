require 'spec_helper'

describe Fora do
  
  describe '[class]' do

    subject { Fora }

    its(:foræ) { should be_an Array }
    its(:platforms) { should be_an Array }
    its(:test_uris) { should be_an Array }
  end

  describe '[instance]' do

    subject { Fora.new }

  end
end
