# encoding: UTF-8
# coding: UTF-8
# -*- coding: UTF-8 -*-

require 'spec_helper'

describe Fora do
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

      # NOTE: fully disabled because these are unit tests
      context 'with selenium disabled' do
        before do
          allow(Selenium::WebDriver).to receive(:for).and_return(Selenium::FakeDriver.new)
          allow_any_instance_of(Selenium::FakeDriver).to receive(:find_element).and_return(nil)
          allow_any_instance_of(Selenium::FakeDriver).to receive(:find_elements).and_return([])
          allow_any_instance_of(Selenium::FakeDriver).to receive(:get).and_return(true)
        end

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

        describe '#viewing_a_topic?' do
          #
          it 'should not raise_error' do
            expect { subject.viewing_a_topic? }.to_not raise_error
          end
        end

        describe '#viewing_a_topic?' do
          #
          it 'should not raise_error' do
            expect { subject.viewing_a_topic? }.to_not raise_error
          end
        end

        describe 'topic_is_locked?' do
          #
          it 'should not raise_error' do
            expect { subject.topic_is_locked? }.to_not raise_error
          end
        end

        describe 'viewing_my_topic?' do
          #
          it 'should not raise_error' do
            expect { subject.viewing_my_topic? }.to_not raise_error
          end
        end

        describe 'my_replies' do
          #
          it 'should not raise_error' do
            expect { subject.my_replies }.to_not raise_error
          end

          it 'should be empty' do
            expect(subject.my_replies).to be_empty
          end
        end

        describe 'replies_to_me' do
          #
          it 'should not raise_error' do
            expect { subject.replies_to_me }.to_not raise_error
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
          describe '(protected methods)' do
            describe 'topic_page_selector' do
              #
              it 'has safe defaults' do
                expect(subject.platform.send(:topic_page_selector)).to be_blank
              end
            end

            describe 'topics_links_selector' do
              #
              it 'has safe defaults' do
                expect(subject.platform.send(:topics_links_selector)).to be_blank
              end
            end

            describe 'my_topic_selector' do
              #
              it 'has safe defaults' do
                expect(subject.platform.send(:my_topic_selector)).to be_blank
              end
            end

            describe 'my_replies_selector' do
              #
              it 'has safe defaults' do
                expect(subject.platform.send(:my_replies_selector)).to be_blank
              end
            end

            describe 'replies_to_me_selector' do
              #
              it 'has safe defaults' do
                expect(subject.platform.send(:replies_to_me_selector)).to be_blank
              end
            end

            describe 'locked_topic_selector' do
              #
              it 'has safe defaults' do
                expect(subject.platform.send(:locked_topic_selector)).to be_blank
              end
            end
          end
        end
      end
    end
  end
end
