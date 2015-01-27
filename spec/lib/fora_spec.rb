# encoding: UTF-8
# coding: UTF-8
# -*- coding: UTF-8 -*-

require 'spec_helper'

describe Fora, selenium: false do
  describe '[class]' do
    subject { Fora }

    its(:forae) { should be_an Array }
    its(:platforms) { should be_an Array }
    its(:test_uris) { should be_an Array }
  end

  let(:valid_options) { YAML.load(ERB.new(File.binread('spec/fixtures/forae.yaml')).result)[:forae].first }

  describe '[instance]' do
    after do
      subject.try(:teardown)
    end

    context 'with valid options' do
      subject { Fora.new(valid_options) }

      it 'successfully initializes' do
        expect { subject }.to_not raise_error
      end

      describe '#topics' do
        it 'is an Array' do
          expect(subject.topics).to be_an Array
        end
      end

      describe '#wait_times' do
        #
        it 'is a Hash' do
          expect(subject.wait_times).to be_a Hash
        end
      end

      context 'with empty selectors' do
        before do
          allow_any_instance_of(Fora).to receive(:dom_selectors).and_return({})
        end

        describe '#topics' do
          it 'is empty' do
            expect(subject.topics).to be_empty
          end
        end

        describe '#visit' do
          it 'is truthy' do
            expect(subject.visit).to be_truthy
          end
        end
      end
    end
  end
end
