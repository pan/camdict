# frozen_string_literal: true
require 'camdict/client'
require 'camdict/definition'

module Camdict
  # Get all definitions data about a word or phrase including IPAs,
  # pronunciations, usage sentences, etc. from Cambridge dictionary.
  class Word
    # New a +word+ or phrase, default +dictionary+ is british.
    def initialize(word, dictionary = nil)
      @word = word
      @dictionary = dictionary
    end

    def part_of_speech
      s = definition.senses.map(&:part_of_speech).uniq
      return s.first if s.count < 2
      s
    end

    def pronunciation(region = :uk)
      p = definition.pronunciation.send(region)
      p.mp3 || p.ogg
    end

    def ipa(region = :uk)
      definition.ipa.send(region)
    end

    def meaning
      definition.senses.first.explanations.first.meaning
    end

    def meanings
      definition.senses.map { |s| s.explanations.map(&:meaning) }.flatten
    end

    # show all important dictionary information, returns
    # { meaning: [{ pos: '', category: '', level: '', code: '',
    #             sense: [{ meaning:, eg: [] }] }]
    #   ipa: '' | { uk: , us: },
    #   pronunciation: { uk: mp3|ogg, us: mp3|ogg }
    # }
    def show
      {
        meaning: meanings_json,
        ipa: ipa_json,
        pronunciation: { uk: pronunciation, us: pronunciation(:us) }
      }
    end

    def print
      require 'pp'
      pp show
    end

    def definition
      definitions.first
    end

    # Get all definitions for this word from remote online dictionary
    def definitions
      @definitions ||= g_definitions
    end

    def raw_definition
      @raw_definition ||= retrieve.to_html(save_with: 0)
    end

    alias pos part_of_speech

    private

    def retrieve
      @retrieved ||= Camdict::Client.new(@dictionary).html_definition(@word)
    end

    def g_definitions
      retrieve.map { |hdef| Camdict::Definition.new(@word).parse(hdef) }
    end

    def meanings_json
      definition.senses.map do |s|
        {
          pos: s.part_of_speech, category: s.category,
          sense: s.explanations.map do |e|
            { meaning: e.meaning, eg: e.examples&.map(&:sentence) }
          end
        }
      end
    end

    def ipa_json
      ipa(:uk) == ipa(:us) ? ipa : { uk: ipa(:uk), us: ipa(:us) }
    end
  end
end
