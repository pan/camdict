# frozen_string_literal: true
require 'camdict/common'
require 'camdict/sentence'

module Camdict
  # Explanation are inside the def-block node.
  class Explanation
    # Elementary level. It's a symbol indicating the level when learners know
    # this meaning.
    #   A1: Beginner,       A2: Elementary,
    #   B1: Intermediate,   B2: Upper-Intermediate,
    #   C1: Advanced,       C2: Proficiency
    attr_reader :level

    # Get example sentences
    attr_reader :examples

    # Get synonym word
    attr_reader :synonym

    # Get opposite word
    attr_reader :opposite

    # A meaning of the word
    attr_reader :meaning

    # One or two words usage note. For example, slang.
    attr_reader :usage

    # The meaning is used in which region - UK or US.
    attr_reader :region

    # For a specific explanation, the word may have a variant form.
    attr_reader :variant

    # Grammar code. Full list is http://dictionary.cambridge.org/help/codes.html
    attr_reader :code

    # Parse +html+ to get level, meaning, example sentences, synonym, opposite,
    # usage, grammar code, region, variant.
    def initialize(html)
      @level = get_level(html)                      # String
      @variant = get_variant(html)                  # String
      @meaning = get_meaning(html)                  # String
      @code = css_text(html, '.gcs')                # String
      @usage = css_text(html, '.usage')             # String
      @region = css_text(html, '.region')           # String
      @examples = get_examples(html)                # [Sentence]
      @synonym = get_synonym(html)                  # String
      @opposite = get_opposite(html)                # String
      # todo: add usage panel - the word: somewhere.
    end

    private

    # A meaning may have a symbol representing the difficulty from A1-C2.
    def get_level(html)
      css_text html, '.def-info .epp-xref'
    end

    # For an explanation, it may have a variant form word or phrase which has
    # same meaning.
    def get_variant(html)
      css_text html, ".v[title='Variant form']"
    end

    # The meaning of a word for this explanation.
    def get_meaning(html)
      css_text(html, '.def')
    end

    # Get example sentences. Returned results are Sentence or nil.
    def get_examples(html)
      nodes = html.css('.examp')
      return if nodes.empty?
      @examples = nodes.map { |node| Camdict::Sentence.new(node) }
    end

    # Parse and get synonym word
    def get_synonym(html)
      css_text html, ".entry-xref[type='Synonym'] .x-h"
    end

    # Parse and get opposite word
    def get_opposite(html)
      css_text html, ".entry-xref[type='Opposite'] .x-h"
    end

    include Camdict::Common
  end
end
