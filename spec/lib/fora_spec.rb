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

      context 'with selenium disabled' do
        before do
          allow(Selenium::WebDriver).to receive(:for).and_return(Selenium::FakeDriver.new)
          allow_any_instance_of(Selenium::FakeDriver).to receive(:find_elements).and_return([])
        end

        it 'successfully initializes' do
          expect { subject }.to_not raise_error
        end

        describe '#topics' do
          it 'is Array' do
            expect(subject.topics).to be_an Array
          end
        end

        describe '#viewing_a_topic?' do
          #
        end
        describe 'topic_is_locked?' do
          #
        end
        describe 'viewing_my_topic?' do
          #
        end
        describe 'my_replies' do
          #
        end
        describe 'replies_to_me' do
          #
        end
        context '(protected methods)' do
          context 'with empty selectors' do
            before do
              expect_any_instance_of(Fora).to receive(:dom_selectors).and_return({})
            end

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
