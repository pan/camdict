# frozen_string_literal: true
require 'camdict/common'

module Camdict
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
      @usage = get_usage(html)
      @sentence = get_sentence(html)
    end

    private

    # Parse html node under block gcs or usage to get its grammar code or
    # usage info for this sentence.
    def get_usage(html)
      css_text(html, '.gcs') || css_text(html, '.usage')
    end

    # Get sentence inside example block(.eg).
    def get_sentence(html)
      css_text(html, '.eg')
    end

    include Camdict::Common
  end
end
