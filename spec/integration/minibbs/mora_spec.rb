# encoding: UTF-8
# coding: UTF-8
# -*- coding: UTF-8 -*-

require 'spec_helper'

describe Mora, selenium: true, integration: true, unit: false do
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
        let(:fora) { Fora.new valid_options }
        subject { Mora.new fora: fora }

        it 'successfully initializes' do
          expect { subject }.to_not raise_error
        end

        context 'with HTML fixtures' do
          before do
            # modify the method's return values to be local paths
            expect(subject.fora).to receive(:url_for).at_least(:once) do |args|
              # puts args.inspect
              "file://#{args[:path]}"
            end
          end

          it 'loads the correct fixture' do
            expect(@selenium).to receive(:get).with("file://#{root_html_file}").and_call_original
            subject.fora.visit root_html_file
          end

          context 'at the root page' do
            before do
              subject.fora.visit root_html_file
            end

            describe '#read_this_page' do
              it 'is true' do
                expect(subject.read_this_page).to eq true
              end

              it 'does not call #check_my_replies' do
                expect(subject).to_not receive(:check_my_replies)
                subject.read_this_page
              end
            end
          end

          context 'at a topic page' do
            before do
              subject.fora.visit topic_html_file
            end

            describe '#read_this_page' do
              it 'is true' do
                expect(subject.read_this_page).to eq true
              end

              it 'calls #check_my_replies' do
                expect(subject).to receive(:check_my_replies)
                subject.read_this_page
              end
            end
          end

          context 'at a locked topic page' do
            before do
              subject.fora.visit topic_locked_html_file
            end

            describe '#read_this_page' do
              it 'is true' do
                expect(subject.read_this_page).to eq true
              end

              it 'does not call #check_my_replies' do
                expect(subject).to_not receive(:check_my_replies)
                subject.read_this_page
              end
            end
          end

          context 'at my topic page' do
            before do
              subject.fora.visit topic_mine_html_file
            end

            describe '#read_this_page' do
              it 'is true' do
                expect(subject.read_this_page).to eq true
              end

              it 'calls #check_my_replies' do
                expect(subject).to receive(:check_my_replies)
                subject.read_this_page
              end
            end
          end

          context 'at the new topic page' do
            before do
              subject.fora.visit topic_posting_html_file
            end

            describe '#read_this_page' do
              it 'is true' do
                expect(subject.read_this_page).to eq true
              end

              it 'does not call #check_my_replies' do
                expect(subject).to_not receive(:check_my_replies)
                subject.read_this_page
              end
            end
          end

          context 'on a page with replies written by me' do
            before do
              subject.fora.visit reply_by_me_html_file
            end

            describe '#read_this_page' do
              it 'is true' do
                expect(subject.read_this_page).to eq true
              end

              it 'calls #check_my_replies' do
                expect(subject).to receive(:check_my_replies)
                subject.read_this_page
              end
            end
          end

          context 'on a page with replies addressed to me' do
            before do
              subject.fora.visit reply_to_me_html_file
            end

            describe '#read_this_page' do
              it 'is true' do
                expect(subject.read_this_page).to eq true
              end

              it 'calls #check_my_replies' do
                expect(subject).to receive(:check_my_replies)
                subject.read_this_page
              end
            end
          end
        end
      end
    end
  end
end
