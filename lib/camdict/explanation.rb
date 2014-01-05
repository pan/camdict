require 'camdict/common'

module Camdict
  # Explanation are inside the def-block node.
  class Explanation

    # Elementary level. It's a symbol indicating the level when learnders know
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
    attr_reader :gc

    # Parse +html+ to get level, meaning, example sentences, synonym, opposite,
    # usage, grammar code, region, variant.
    def initialize(html)
      @html = html
      @level = get_level                      # String
      @variant = get_variant                  # String
      @meaning = get_meaning                  # String
      @gc = css_text(".gcs")                  # String
      @usage = css_text(".usage")             # String
      @region = css_text(".region")           # String
      @examples = get_examples                # [Sentence]
      @synonym = get_synonym                  # String
      @opposite = get_opposite                # String
      # todo: add usage panel - the word: somewhere.
    end

    private
    # A meaning may have a symbol representing the difficulty from A1-C2.
    def get_level
      css_text ".def-info .epp-xref"
    end

    # For an explanation, it may have a variant form word or phrase which has
    # same meaning.
    def get_variant
      css_text ".v[title='Variant form']"
    end

    # The meaning of a word for this explanation.
    def get_meaning
      css_text(".def")
    end

    # Get example sentences. Returned results are Sentence or nil.
    def get_examples
      nodes = @html.css(".examp")
      unless nodes.empty?
        @examples = nodes.map { |node| 
          Camdict::Explanation::Sentence.new(node)
        }
      end
    end

    # Parse and get synonym word
    def get_synonym
      css_text ".entry-xref[type='Synonym'] .x-h"
    end

    # Parse and get opposite word
    def get_opposite
      css_text ".entry-xref[type='Opposite'] .x-h"
    end

    include Camdict::Common

    # Parse the html to get the example sentence and its typical usage
    # information associated with this sentence.
    class Sentence
      # Get the grammar code or usage in this sentence.
      # It means how the word is used in this sentence. 
      # For example, a grammar code for the word - 
      # 'somewhere' is "+to infinitive". I'm looking for somewhere to eat.
      attr_reader :usage

      # Get one sentence inside an example block.
      attr_reader :sentence

      # New a sentence object from +html+ containing the eg block.
      def initialize(html)
        @html = html
        @usage = get_usage
        @sentence = get_sentence
      end

      private 
      # Parse html node under block gcs or usage to get its grammar code or 
      # usage info for this sentence.
      def get_usage
        css_text(".gcs") || css_text(".usage")
      end

      # Get sentence inside example block(.eg).
      def get_sentence
        css_text(".eg")
      end

      include Camdict::Common
    end

  end
end
