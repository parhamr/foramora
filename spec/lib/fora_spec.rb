require 'spec_helper'

describe Fora do
  describe '[class]' do
    subject { Fora }

    its(:foræ) { should be_an Array }
    its(:platforms) { should be_an Array }
    its(:test_uris) { should be_an Array }
  end

  let(:valid_options) { YAML.load(ERB.new(File.binread('spec/fixtures/foræ.yaml')).result)[:foræ].first }

  describe '[instance]' do
    after do
      subject.try(:teardown)
    end

    context 'with valid options' do
      subject { Fora.new(valid_options) }

      it 'successfully initializes' do
        expect { subject }.to_not raise_error
      end
    end
  end
end
