# encoding: UTF-8
# coding: UTF-8
# -*- coding: UTF-8 -*-

require 'spec_helper'

describe Fora, selenium: true, integration: true, unit: false do
  describe '[integration]' do
    before(:all) do
      # initialize and persist a webdriver
      @selenium = Selenium::WebDriver.for RSpec.configuration.selenium_webdriver
    end

    before(:each) do
      # then override
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

    let(:valid_options) { YAML.load(ERB.new(File.binread('spec/fixtures/forae.yaml')).result)[:forae].first }
    let(:minibbs_fixtures_dir) { File.join(__dir__, '..', '..', 'fixtures', 'minibbs') }
    let(:root_html_file) { File.join(minibbs_fixtures_dir, 'index.html') }
    let(:reply_by_me_html_file) { File.join(minibbs_fixtures_dir, 'reply_by_me.html') }
    let(:reply_to_me_html_file) { File.join(minibbs_fixtures_dir, 'reply_to_me.html') }
    let(:topic_html_file) { File.join(minibbs_fixtures_dir, 'topic.html') }
    let(:topic_locked_html_file) { File.join(minibbs_fixtures_dir, 'topic_locked.html') }
    let(:topic_mine_html_file) { File.join(minibbs_fixtures_dir, 'topic_mine.html') }
    let(:topic_posting_html_file) { File.join(minibbs_fixtures_dir, 'topic_posting.html') }

    describe '[instance]' do
      context 'with valid options' do
        subject { Fora.new(valid_options) }

        it 'successfully initializes' do
          expect { subject }.to_not raise_error
        end

        context 'with local file overrides' do
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

          describe '#topics' do
            it 'is an Array' do
              expect(subject.topics root_html_file).to be_an Array
            end
          end
        end
      end
    end
  end
end
