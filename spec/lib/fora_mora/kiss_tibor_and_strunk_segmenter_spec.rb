# encoding: UTF-8
# coding: UTF-8
# -*- coding: UTF-8 -*-
require 'spec_helper'

describe ForaMora::Segmenter::KissTiborAndStrunkSegmenter do
  let(:two_sentences_string) { 'The quick brown fox jumps over the lazy dog. The dog remained asleep.' }
  let(:two_sentences_array) { ['The quick brown fox jumps over the lazy dog.', 'The dog remained asleep.'] }
  let(:two_paragraphs_file_path) { File.join('spec', 'fixtures', 'fora_mora', 'naive_segmenter_file.txt') }
  let(:two_sentences_string_question) { 'Did the fox jump over the dog? I do not know.' }
  let(:two_sentences_string_exclamation) { 'That fox jumped over a dog! The dog remained asleep.' }
  let(:quote_leading_sentence) { 'This is a sentence. "I am sitting on a wall," Humpty Dumpty said. He would later regret that.' }
  let(:quote_inside_sentence) { 'This is a sentence. These “air quotes” are silly. This is a sentence.' }
  let(:quote_ending_sentence) { 'This is a sentence. Humpty Dumpy was heard saying, "I am sitting on a wall." He would later regret that.' }
  let(:uk_english_quote) { '"Humpty Dumpty sat on a wall".' }
  let(:bad_ellipsis) { 'Bad... ellipsis.' }
  let(:bad_em_dash) { 'This is--you see--an em dash.' }
  let(:two_sentences_string_abbreviations) { 'The quick brown U.S.A fox jumps over the lazy Dr. Dog. Dr. Dog remained asleep.' }
  let(:two_sentences_string_initial_lower) { 'This is a stentence. bell hooks is a person. iMac is a trademark' }

  describe '.parse_segment_input' do
    context '(without arguments)' do
      it 'raises ArgumentError' do
        expect { subject.parse_segment_input }.to raise_error
      end
    end

    context 'with nil:NilClass input' do
      it 'returns String' do
        expect(subject.parse_segment_input(nil)).to eq(nil)
      end
    end

    context 'with String input' do
      it 'returns String' do
        expect(subject.parse_segment_input('String')).to eq('String')
      end
    end

    context 'with Array input' do
      it 'returns the first element' do
        expect(subject.parse_segment_input(['String'])).to eq('String')
      end

      context 'of length greater than 1' do
        it 'returns the first element' do
          expect(subject.parse_segment_input(%w(String Word))).to eq('String')
        end
      end
    end

    context 'with File input' do
      it 'returns the file contents' do
        expect(subject.parse_segment_input(File.new(two_paragraphs_file_path))).to eq(File.binread(two_paragraphs_file_path))
      end
    end

    context 'with Fixnum input' do
      it 'returns String' do
        expect(subject.parse_segment_input(1)).to eq('1')
      end
    end

    context 'with Hash input' do
      context 'when empty' do
        it 'returns Hash' do
          expect(subject.parse_segment_input({})).to eq({})
        end
      end

      context 'when present' do
        it 'returns Hash' do
          expect(subject.parse_segment_input(key: 'value')).to be_a Hash
        end
      end
    end

    context 'with Time input' do
      it 'returns String' do
        expect(subject.parse_segment_input(Time.now)).to be_a String
      end
    end
  end

  describe '.text_cleanup' do
    context '(without arguments)' do
      it 'raises error' do
        expect { subject.text_cleanup }.to raise_error
      end
    end

    context '(with nil argument)' do
      it 'returns without error' do
        expect { subject.text_cleanup(nil) }.to_not raise_error
      end

      it 'returns empty string' do
        expect(subject.text_cleanup(nil)).to eq('')
      end
    end

    context '(with valid arguments)' do
      it 'fixes ellipses' do
        expect(subject.text_cleanup(bad_ellipsis)).to eq('Bad… ellipsis.')
      end

      it 'fixes em-dashes' do
        expect(subject.text_cleanup(bad_em_dash)).to eq('This is—you see—an em dash.')
      end
    end
  end

  describe '.punctuation_ending_sentences' do
    it 'matches simple periods' do
      expect(two_sentences_string.split(subject.punctuation_ending_sentences).length).to eq(2)
    end

    it 'matches simple exclamations' do
      expect(two_sentences_string_exclamation.split(subject.punctuation_ending_sentences).length).to eq(2)
    end

    it 'matches simple questions' do
      expect(two_sentences_string_question.split(subject.punctuation_ending_sentences).length).to eq(2)
    end
  end

  describe '.segment' do
    context '(without arguments)' do
      it 'returns without error' do
        expect { subject.segment }.to_not raise_error
      end

      it 'returns nil' do
        expect(subject.segment).to eq nil
      end
    end

    context 'with String input' do
      let(:args) { two_sentences_string }

      it 'returns without error' do
        expect { subject.segment(args) }.to_not raise_error
      end

      it 'returns Array' do
        expect(subject.segment(args)).to be_an Array
      end

      it 'returns segmented sentences' do
        expect(subject.segment(args)).to eq two_sentences_array
      end

      it 'correctly segments quotes leading sentences' do
        expect(subject.segment(quote_leading_sentence).length).to eq 3
      end

      it 'correctly segments quotes inside sentences' do
        expect(subject.segment(quote_inside_sentence).length).to eq 3
      end

      it 'correctly segments quotes ending sentences' do
        expect(subject.segment(quote_ending_sentence).length).to eq 3
      end

      it 'correctly segments bad punctuation' do
        expect(subject.segment(bad_ellipsis).length).to eq 1
      end

      it 'correctly segments abbreviation' do
        expect(subject.segment(two_sentences_string_abbreviations).length).to eq 2
      end

      it 'correctly segments lowercase initials' do
        expect(subject.segment(two_sentences_string_initial_lower).length).to eq 2
      end

      context 'and options' do
        let(:args) { [two_sentences_string, { option: 'value' }] }

        it 'returns without error' do
          expect { subject.segment(args) }.to_not raise_error
        end

        it 'returns segmented sentences' do
          expect(subject.segment(args)).to eq two_sentences_array
        end
      end
    end

    context 'with Array input' do
      let(:args) { two_sentences_array }

      it 'returns without error' do
        expect { subject.segment(args) }.to_not raise_error
      end

      it 'returns Array' do
        expect(subject.segment(args)).to be_an Array
      end
    end

    context 'with File input' do
      let(:args) { File.new(two_paragraphs_file_path, 'rb') }

      it 'returns without error' do
        expect { subject.segment(args) }.to_not raise_error
      end

      it 'returns Array' do
        expect(subject.segment(args)).to be_an Array
      end
    end
  end
end
