# encoding: UTF-8
# coding: UTF-8
# -*- coding: UTF-8 -*-

require 'spec_helper'

describe Fora, selenium: true, integration: true, unit: false do
  describe '[integration]' do
    before(:all) do
      # initialize and hold a webdriver
      @selenium = Selenium::WebDriver.for RSpec.configuration.selenium_webdriver
    end

    before(:each) do
      # then override, returning the in-memory driver
      allow(Selenium::WebDriver).to receive(:for).and_return(@selenium)
    end

    after(:each) do
      # let the browser be visible
      # sleep 1
    end

    after(:all) do
      # close the driver
      @selenium.try(:quit)
    end

    let(:valid_options)           { YAML.load(ERB.new(File.binread('spec/fixtures/forae.yaml')).result)[:forae].first }
    # FIXME: relative path traversal is ugly
    let(:minibbs_fixtures_dir)    { File.join(__dir__, '..', '..', 'fixtures', 'minibbs') }
    let(:root_html_file)          { File.join(minibbs_fixtures_dir, 'index.html') }
    let(:reply_by_me_html_file)   { File.join(minibbs_fixtures_dir, 'reply_by_me.html') }
    let(:reply_to_me_html_file)   { File.join(minibbs_fixtures_dir, 'reply_to_me.html') }
    let(:topic_html_file)         { File.join(minibbs_fixtures_dir, 'topic.html') }
    let(:topic_locked_html_file)  { File.join(minibbs_fixtures_dir, 'topic_locked.html') }
    let(:topic_mine_html_file)    { File.join(minibbs_fixtures_dir, 'topic_mine.html') }
    let(:topic_posting_html_file) { File.join(minibbs_fixtures_dir, 'topic_posting.html') }

    describe '[instance]' do
      context 'with valid options' do
        subject { Fora.new(valid_options) }

        it 'successfully initializes' do
          expect { subject }.to_not raise_error
        end

        context 'with HTML fixtures' do
          before do
            # modify the method's return values to be local paths
            expect(subject).to receive(:url_for).at_least(:once) do |args|
              # puts args.inspect
              "file://#{args[:path]}"
            end
          end

          it 'loads the correct fixture' do
            expect(@selenium).to receive(:get).with("file://#{root_html_file}").and_call_original
            subject.visit root_html_file
          end

          context 'at the root page' do
            before do
              subject.visit root_html_file
            end

            describe '#topics' do
              it 'is an Array' do
                expect(subject.topics root_html_file).to be_an Array
              end

              it 'finds 20 topics' do
                expect(subject.topics(root_html_file).length).to eq 20
              end

              it 'contains Selenium::WebDriver::Element objects' do
                subject.topics(root_html_file).each do |e|
                  expect(e).to be_a Selenium::WebDriver::Element
                end
              end

              it 'calls platform.store_topics' do
                expect(subject.platform).to receive(:store_topics).with(any_args)
                subject.topics(root_html_file)
              end
            end

            describe '#known_topics' do
              it 'is a Hash' do
                expect(subject.known_topics).to be_a Hash
              end

              it 'is empty by default' do
                expect(subject.known_topics).to eq({})
              end
            end

            context 'when calling #topics' do
              before do
                subject.topics root_html_file
              end

              describe '#known_topics' do
                it 'contains 20 topics' do
                  expect(subject.known_topics.length).to eq 20
                end
              end
            end

            describe '#my_replies' do
              it 'is an Array' do
                expect(subject.my_replies).to be_an Array
              end

              it 'is empty' do
                expect(subject.my_replies).to be_empty
              end
            end

            describe '#replies_to_me' do
              it 'is an Array' do
                expect(subject.replies_to_me).to be_an Array
              end

              it 'is empty' do
                expect(subject.replies_to_me).to be_empty
              end
            end

            describe '#viewing_a_topic?' do
              it 'is falsey' do
                expect(subject.viewing_a_topic?).to be_falsey
              end
            end

            describe '#topic_is_locked?' do
              it 'is truthy' do
                expect(subject.topic_is_locked?).to be_truthy
              end
            end

            describe '#viewing_my_topic?' do
              it 'is falsey' do
                expect(subject.viewing_my_topic?).to be_falsey
              end
            end
          end

          context 'at a topic page' do
            before do
              subject.visit topic_html_file
            end

            describe '#topics' do
              it 'is an Array' do
                expect(subject.topics topic_html_file).to be_an Array
              end

              it 'finds 0 topics' do
                expect(subject.topics(topic_html_file).length).to eq 0
              end
            end

            describe '#known_topics' do
              it 'is a Hash' do
                expect(subject.known_topics).to be_a Hash
              end
            end

            describe '#my_replies' do
              it 'is an Array' do
                expect(subject.my_replies).to be_an Array
              end

              it 'is empty' do
                expect(subject.my_replies).to be_empty
              end
            end

            describe '#replies_to_me' do
              it 'is an Array' do
                expect(subject.replies_to_me).to be_an Array
              end

              it 'is empty' do
                expect(subject.replies_to_me).to be_empty
              end
            end

            describe '#viewing_a_topic?' do
              it 'is truthy' do
                expect(subject.viewing_a_topic?).to be_truthy
              end
            end

            describe '#topic_is_locked?' do
              it 'is falsey' do
                expect(subject.topic_is_locked?).to be_falsey
              end
            end

            describe '#viewing_my_topic?' do
              it 'is falsey' do
                expect(subject.viewing_my_topic?).to be_falsey
              end
            end
          end

          context 'at a locked topic page' do
            before do
              subject.visit topic_locked_html_file
            end

            describe '#topics' do
              it 'is an Array' do
                expect(subject.topics topic_html_file).to be_an Array
              end

              it 'finds 0 topics' do
                expect(subject.topics(topic_html_file).length).to eq 0
              end
            end

            describe '#known_topics' do
              it 'is a Hash' do
                expect(subject.known_topics).to be_a Hash
              end
            end

            describe '#my_replies' do
              it 'is an Array' do
                expect(subject.my_replies).to be_an Array
              end

              it 'is empty' do
                expect(subject.my_replies).to be_empty
              end
            end

            describe '#replies_to_me' do
              it 'is an Array' do
                expect(subject.replies_to_me).to be_an Array
              end

              it 'is empty' do
                expect(subject.replies_to_me).to be_empty
              end
            end

            describe '#viewing_a_topic?' do
              it 'is truthy' do
                expect(subject.viewing_a_topic?).to be_truthy
              end
            end

            describe '#topic_is_locked?' do
              it 'is truthy' do
                expect(subject.topic_is_locked?).to be_truthy
              end
            end

            describe '#viewing_my_topic?' do
              it 'is falsey' do
                expect(subject.viewing_my_topic?).to be_falsey
              end
            end
          end

          context 'at my topic page' do
            before do
              subject.visit topic_mine_html_file
            end

            describe '#topics' do
              it 'is an Array' do
                expect(subject.topics topic_html_file).to be_an Array
              end

              it 'finds 0 topics' do
                expect(subject.topics(topic_html_file).length).to eq 0
              end
            end

            describe '#known_topics' do
              it 'is a Hash' do
                expect(subject.known_topics).to be_a Hash
              end
            end

            describe '#my_replies' do
              it 'is an Array' do
                expect(subject.my_replies).to be_an Array
              end

              it 'contains 1 reply' do
                expect(subject.my_replies.length).to eq 1
              end
            end

            describe '#replies_to_me' do
              it 'is an Array' do
                expect(subject.replies_to_me).to be_an Array
              end

              it 'is empty' do
                expect(subject.replies_to_me).to be_empty
              end
            end

            describe '#viewing_a_topic?' do
              it 'is true' do
                expect(subject.viewing_a_topic?).to eq true
              end
            end

            describe '#topic_is_locked?' do
              it 'is false' do
                expect(subject.topic_is_locked?).to eq false
              end
            end

            describe '#viewing_my_topic?' do
              it 'is truthy' do
                expect(subject.viewing_my_topic?).to be_truthy
              end

              it 'returns the topic post' do
                expect(subject.viewing_my_topic?).to be_a(Selenium::WebDriver::Element)
              end
            end
          end

          context 'at the new topic page' do
            before do
              subject.visit topic_posting_html_file
            end

            describe '#topics' do
              it 'is an Array' do
                expect(subject.topics topic_html_file).to be_an Array
              end

              it 'finds 0 topics' do
                expect(subject.topics(topic_html_file).length).to eq 0
              end
            end

            describe '#known_topics' do
              it 'is a Hash' do
                expect(subject.known_topics).to be_a Hash
              end
            end

            describe '#my_replies' do
              it 'is an Array' do
                expect(subject.my_replies).to be_an Array
              end

              it 'is empty' do
                expect(subject.my_replies).to be_empty
              end
            end

            describe '#replies_to_me' do
              it 'is an Array' do
                expect(subject.replies_to_me).to be_an Array
              end

              it 'is empty' do
                expect(subject.replies_to_me).to be_empty
              end
            end

            describe '#viewing_a_topic?' do
              it 'is false' do
                expect(subject.viewing_a_topic?).to eq false
              end
            end

            describe '#topic_is_locked?' do
              it 'is true' do
                expect(subject.topic_is_locked?).to eq true
              end
            end

            describe '#viewing_my_topic?' do
              it 'is false' do
                expect(subject.viewing_my_topic?).to eq false
              end
            end
          end

          context 'on a page with replies written by me' do
            before do
              subject.visit reply_by_me_html_file
            end

            describe '#topics' do
              it 'is an Array' do
                expect(subject.topics topic_html_file).to be_an Array
              end

              it 'finds 0 topics' do
                expect(subject.topics(topic_html_file).length).to eq 0
              end
            end

            describe '#known_topics' do
              it 'is a Hash' do
                expect(subject.known_topics).to be_a Hash
              end
            end

            describe '#my_replies' do
              it 'is an Array' do
                expect(subject.my_replies).to be_an Array
              end

              it 'is contains 1 reply' do
                expect(subject.my_replies.length).to eq 1
              end

              it 'contains Selenium::WebDriver::Element objects' do
                subject.my_replies.each do |e|
                  expect(e).to be_a Selenium::WebDriver::Element
                end
              end
            end

            describe '#replies_to_me' do
              it 'is an Array' do
                expect(subject.replies_to_me).to be_an Array
              end

              it 'is empty' do
                expect(subject.replies_to_me).to be_empty
              end
            end

            describe '#viewing_a_topic?' do
              it 'is true' do
                expect(subject.viewing_a_topic?).to eq true
              end
            end

            describe '#topic_is_locked?' do
              it 'is false' do
                expect(subject.topic_is_locked?).to eq false
              end
            end

            describe '#viewing_my_topic?' do
              it 'is false' do
                expect(subject.viewing_my_topic?).to eq false
              end
            end
          end

          context 'on a page with replies addressed to me' do
            before do
              subject.visit reply_to_me_html_file
            end

            describe '#topics' do
              it 'is an Array' do
                expect(subject.topics topic_html_file).to be_an Array
              end

              it 'finds 0 topics' do
                expect(subject.topics(topic_html_file).length).to eq 0
              end
            end

            describe '#known_topics' do
              it 'is a Hash' do
                expect(subject.known_topics).to be_a Hash
              end
            end

            describe '#my_replies' do
              it 'is an Array' do
                expect(subject.my_replies).to be_an Array
              end

              it 'is contains 1 reply' do
                expect(subject.my_replies.length).to eq 2
              end

              it 'contains Selenium::WebDriver::Element objects' do
                subject.my_replies.each do |e|
                  expect(e).to be_a Selenium::WebDriver::Element
                end
              end
            end

            describe '#replies_to_me' do
              it 'is an Array' do
                expect(subject.replies_to_me).to be_an Array
              end

              it 'contains 1 reply' do
                expect(subject.replies_to_me.length).to eq 1
              end

              it 'contains Selenium::WebDriver::Element objects' do
                subject.replies_to_me.each do |e|
                  expect(e).to be_a Selenium::WebDriver::Element
                end
              end
            end

            describe '#viewing_a_topic?' do
              it 'is true' do
                expect(subject.viewing_a_topic?).to eq true
              end
            end

            describe '#topic_is_locked?' do
              it 'is false' do
                expect(subject.topic_is_locked?).to eq false
              end
            end

            describe '#viewing_my_topic?' do
              it 'is false' do
                expect(subject.viewing_my_topic?).to eq false
              end
            end
          end
        end
      end
    end
  end
end
