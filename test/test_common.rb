# frozen_string_literal: true
require_relative 'helper'

module Camdict
  class CommonTest < Minitest::Test
    include Camdict::Common

    def test_phrase_css
      @word = 'be in difficulty'
      ret = ''
      phrase_css(Nokogiri::HTML(html), '.def-block') do |node|
        ret = Camdict::Explanation.new(node)
      end
      assert_equal sentence, ret.examples.first.sentence
      assert_equal meaning, ret.meaning
    end

    private

    def meaning
      'to have problems or be in difficult situation:'
    end

    def sentence
      'a ship is in difficluties off the coast of Ireland.'
    end

    def html
      '<span class="phrase-block">' \
        '<span class="phrase">be in difficulties</span>' \
        '<span class="v" title="Variant form">be in difficulty</span>' \
        '<span class="phrase-body">' \
          "<span class='def-block'><span class='def'>#{meaning}</span>" \
            "<span class='examp'><span class='eg'>#{sentence}</span></span>"
    end
  end
end
