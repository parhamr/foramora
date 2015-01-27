# encoding: UTF-8
# coding: UTF-8
# -*- coding: UTF-8 -*-

require 'spec_helper'

describe Forae::Test, selenium: false do
  describe '[class]' do
    subject { Forae::Default }
  end

  let(:valid_fora_options) { YAML.load(ERB.new(File.binread('spec/fixtures/forae.yaml')).result)[:forae].first }

  describe '[instance]' do
    let(:fora) { Fora.new(valid_fora_options) }
    subject { Forae::Default.new(fora: fora) }

    context 'with valid options' do
      let(:dom_selector) { { type: :css, expression: 'CSS selector goes here', returns: :one } }

      it 'successfully initializes' do
        expect { subject }.to_not raise_error
      end

      describe '#viewing_a_topic?' do
        #
        it 'does not raise_error' do
          expect { subject.viewing_a_topic? }.to_not raise_error
        end

        it 'is falsey' do
          expect(subject.viewing_a_topic?).to be_falsey
        end

        context 'when #call_driver_finder is truthy' do
          before do
            expect(subject).to receive(:call_driver_finder).
              at_least(:once).
              and_return('element')
          end

          it 'is truthy' do
            expect(subject.viewing_a_topic?).to be_truthy
          end
        end
      end

      describe 'topic_is_locked?' do
        #
        it 'does not raise_error' do
          expect { subject.topic_is_locked? }.to_not raise_error
        end

        it 'is truthy' do
          expect(subject.topic_is_locked?).to be_truthy
        end

        context '(and viewing_a_topic? is true)' do
          before do
            expect(subject).to receive(:viewing_a_topic?).
              at_least(:once).
              and_return(true)
          end

          context '(when #call_driver_finder is truthy)' do
            before do
              expect(subject).to receive(:call_driver_finder).
                at_least(:once).
                and_return('element')
            end

            it 'is truthy' do
              expect(subject.topic_is_locked?).to be_truthy
            end
          end

          context '(when #call_driver_finder is falsey)' do
            before do
              expect(subject).to receive(:call_driver_finder).
                at_least(:once).
                and_return(false)
            end

            it 'is falsey' do
              expect(subject.topic_is_locked?).to be_falsey
            end
          end
        end
      end

      describe 'viewing_my_topic?' do
        #
        it 'does not raise_error' do
          expect { subject.viewing_my_topic? }.to_not raise_error
        end

        it 'is falsey' do
          expect(subject.viewing_my_topic?).to be_falsey
        end
      end

      describe 'my_replies' do
        #
        it 'does not raise_error' do
          expect { subject.my_replies }.to_not raise_error
        end

        it 'is empty' do
          expect(subject.my_replies).to be_empty
        end
      end

      describe 'replies_to_me' do
        #
        it 'does not raise_error' do
          expect { subject.replies_to_me }.to_not raise_error
        end

        it 'is empty' do
          expect(subject.replies_to_me).to be_empty
        end
      end

      describe '(protected methods)' do
        describe 'topic_page_selector' do
          #
          it 'is a Hash' do
            expect(subject.send(:topic_page_selector)).to be_a Hash
          end
        end

        describe 'topics_links_selector' do
          #
          it 'is a Hash' do
            expect(subject.send(:topics_links_selector)).to be_a Hash
          end
        end

        describe 'my_topic_selector' do
          #
          it 'is a Hash' do
            expect(subject.send(:my_topic_selector)).to be_a Hash
          end
        end

        describe 'my_replies_selector' do
          #
          it 'is a Hash' do
            expect(subject.send(:my_replies_selector)).to be_a Hash
          end

          it 'has a fixture' do
            expect(subject.send(:my_replies_selector)).to be_present
          end
        end

        describe 'replies_to_me_selector' do
          #
          it 'is a Hash' do
            expect(subject.send(:replies_to_me_selector)).to be_a Hash
          end

          it 'has a fixture' do
            expect(subject.send(:replies_to_me_selector)).to be_present
          end
        end

        describe 'locked_topic_selector' do
          #
          it 'is a Hash' do
            expect(subject.send(:locked_topic_selector)).to be_a Hash
          end

          it 'has a fixture' do
            expect(subject.send(:locked_topic_selector)).to be_present
          end
        end
      end

      context 'with empty selectors' do
        before do
          allow_any_instance_of(Fora).to receive(:dom_selectors).and_return({})
        end

        describe '#viewing_a_topic?' do
          #
          it 'does not raise_error' do
            expect { subject.viewing_a_topic? }.to_not raise_error
          end

          it 'is falsey' do
            expect(subject.viewing_a_topic?).to be_falsey
          end
        end

        describe 'topic_is_locked?' do
          #
          it 'does not raise_error' do
            expect { subject.topic_is_locked? }.to_not raise_error
          end

          it 'is truthy' do
            expect(subject.topic_is_locked?).to be_truthy
          end

          context '(and viewing a topic is true)' do
            before do
              expect(subject).to receive(:viewing_a_topic?).
                at_least(:once).
                and_return(true)
            end

            it 'is falsey' do
              expect(subject.topic_is_locked?).to be_falsey
            end
          end
        end

        describe 'viewing_my_topic?' do
          #
          it 'does not raise_error' do
            expect { subject.viewing_my_topic? }.to_not raise_error
          end

          it 'is falsey' do
            expect(subject.viewing_my_topic?).to be_falsey
          end
        end

        describe 'my_replies' do
          #
          it 'does not raise_error' do
            expect { subject.my_replies }.to_not raise_error
          end

          it 'is empty' do
            expect(subject.my_replies).to be_empty
          end
        end

        describe 'replies_to_me' do
          #
          it 'does not raise_error' do
            expect { subject.replies_to_me }.to_not raise_error
          end

          it 'is empty' do
            expect(subject.replies_to_me).to be_empty
          end
        end

        describe '(protected methods)' do
          describe 'topic_page_selector' do
            #
            it 'has safe defaults' do
              expect(subject.send(:topic_page_selector)).to be_blank
            end
          end

          describe 'topics_links_selector' do
            #
            it 'has safe defaults' do
              expect(subject.send(:topics_links_selector)).to be_blank
            end
          end

          describe 'my_topic_selector' do
            #
            it 'has safe defaults' do
              expect(subject.send(:my_topic_selector)).to be_blank
            end
          end

          describe 'my_replies_selector' do
            #
            it 'has safe defaults' do
              expect(subject.send(:my_replies_selector)).to be_blank
            end
          end

          describe 'replies_to_me_selector' do
            #
            it 'has safe defaults' do
              expect(subject.send(:replies_to_me_selector)).to be_blank
            end
          end

          describe 'locked_topic_selector' do
            #
            it 'has safe defaults' do
              expect(subject.send(:locked_topic_selector)).to be_blank
            end
          end
        end
      end

      describe '(private methods)' do
        describe '#call_driver_finder' do
          it 'raises error when the argument does not respond to fetch' do
            expect do
              subject.send(:call_driver_finder, '')
            end.to raise_error
          end

          it 'raises error when :returns is unexpected' do
            expect do
              subject.send(:call_driver_finder, dom_selector.merge(returns: :hamburger))
            end.to raise_error
          end

          it 'raises error when :expression is unexpected' do
            expect do
              subject.send(:call_driver_finder, expression: 2.5)
            end.to raise_error
          end

          it 'is false when rescuing Selenium::WebDriver::Error::NoSuchElementError' do
            expect(subject.driver).to receive(:find_element).
              and_raise(Selenium::WebDriver::Error::NoSuchElementError)
            expect(subject.send(:call_driver_finder, dom_selector)).to eq false
          end

          it 'is nil when rescuing Selenium::WebDriver::Error::InvalidSelectorError' do
            expect(subject.driver).to receive(:find_element).
              and_raise(Selenium::WebDriver::Error::InvalidSelectorError)
            expect(subject.send(:call_driver_finder, dom_selector)).to eq nil
          end
        end
      end
    end
  end
end
