# encoding: UTF-8
# coding: UTF-8
# -*- coding: UTF-8 -*-
#
class ForaMora
  #
  module Segmenter
    # Roughly derived from an algorithm in:
    # Kiss, Tibor and Strunk, Jan (2006): Unsupervised Multilingual Sentence Boundary Detection. Computational Linguistics 32: 485-525.
    module KissTiborAndStrunkSegmenter
      PUNCTUATION_ENDING_SENTENCES = /\.|\!|\?/
      PUNCTUATION_INSIDE_SENTENCES = %w(, : ; … [ ] ( ) ' " ‘ ’ “ ”).freeze
      PUNCTUATION_TRANSFORMATIONS = [ # clean up known variances of English
        { match: /\.{2,}/, substitution: '…' }, # bad ellipses into UTF-8 ellipsis
        { match: /\-{2,}/, substitution: '—' }, # double hyphen to em-dash
      ].freeze
      CHARACTERS_TO_SQUEEZE = [ # sequential instances of these characters aren't useful
        '-', # hyphen
        '—', # em-dash
      ]

      def self.segment(*args)
        options = args.extract_options!
        input_text = parse_segment_input(args[0])
        input_text
        input_text
      end

      def self.conditional_split(input)
        if input.respond_to?(:split)
          # use Regexp group to include period in the output
          input.split(/(\.)/)
        else
          input
        end
      end

      def self.parse_segment_input(input)
        case input
        when Array
          # Return the first element because we're globbing arguments
          input[0]
        when File
          # REVIEW: possibly use a block to stream each line?
          File.binread(input)
        when Hash, HashWithIndifferentAccess, NilClass
          input
        else
          # NOTE: add new classes as needed
          input.to_s
        end
      end

      def self.text_cleanup(str)
        text = str.to_s
        punctuation_transformations.each do |hsh|
          text.gsub!(hsh[:match], hsh[:substitution])
        end
        text
      end

      # NOTE: exposed as method for easy mock/stub
      def self.punctuation_ending_sentences
        PUNCTUATION_ENDING_SENTENCES
      end

      # NOTE: exposed as method for easy mock/stub
      def self.punctuation_inside_sentences
        PUNCTUATION_INSIDE_SENTENCES
      end

      # NOTE: exposed as method for easy mock/stub
      def self.punctuation_transformations
        PUNCTUATION_TRANSFORMATIONS
      end

      # NOTE: exposed as method for easy mock/stub
      def self.characters_to_squeeze
        CHARACTERS_TO_SQUEEZE
      end
    end
  end
end
