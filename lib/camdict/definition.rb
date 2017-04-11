# frozen_string_literal: true
require 'camdict/entry'
require 'camdict/ipa'
require 'camdict/pronunciation'

module Camdict
  # Parse an html definition to get explanations, word, IPA, prounciation,
  # part of speech, etc.
  class Definition
    # Get senses for this definition.
    attr_reader :senses

    def initialize(word)
      @word = word
    end

    def parse(html)
      get_ipa(html)
      get_pronunciation(html)
      entry(html)
      self
    end

    private

    def entry(html)
      @senses ||= html.css('.entry-body__el').map { |e| get_senses(e) }.flatten
    end

    # Get the definition page title word, which is either a word or phrase.
    # This is necessary because it doesn't always get the searched
    # word exactly. For instance, searching bald also gets baldness. This is
    # how the online dictionary is organised -- when words having
    # the same root they often share the same explanations.
    # <h2 class="di-title cdo-section-title-hw"><span class="headword">
    # look at sth<span></h2>
    def title_word(html)
      @title_word ||=
        html.css('.di-title.cdo-section-title-hw .headword').first.text
    end

    # Some words have more than one derived words, like plagiarize has two.
    # Return an Array of derived words or nil when no derived word found
    # <span class=runon-title" title="Derived word">
    #   <span class="w">plagiarism
    def derived_words(html)
      @derived_words ||= parse_derived_words(html)
    end

    def parse_derived_words(html)
      node = html.css('[title="Derived word"]')
      node.map(&:content) unless node.empty?
    end

    # Get the variant word or phrase inside di-info block but exclude those
    # inside phrase-block or spelling variant, from where is part of the
    # definition header.
    # Such as, US/UK variant, or hasing the same meaning, but
    # different pronunciation.
    def get_head_variant(html)
      node = html.css(".pos-header .var .v[title='Variant form']")
      node.map(&:text) unless node.empty?
    end

    def head_variant?(html)
      hv = get_head_variant(html)
      hv && hv.include?(@word)
    end

    # Get spelling variants, which have same pronunciations.
    # plagiarize: plagiarise
    def spell_variant(html)
      css_text(html, ".spellvar .v[title='Variant form']")
    end

    # Where are the searched word's part of speech, IPAs, prounciations
    # It could be found either at the position of "title" or "derived",
    # "spellvar"
    # Other places are still "unknown".
    def where(html)
      @location ||=
        if on_title?(html) || spell_variant?(html) || head_variant?(html)
          'title'
        elsif derived_word?(html)
          'derived'
        else
          'unknown'
        end
    end

    def derived_word?(html)
      return false unless derived_words(html) && @derived_words.include?(@word)
      true
    end

    def on_title?(html)
      @word == title_word(html)
    end

    # spelling variant is treated as "title word"
    def spell_variant?(html)
      spell_variant(html) == @word
    end

    include Camdict::Common
    include Camdict::IPA
    include Camdict::Pronunciation
    include Camdict::Entry
  end
end
