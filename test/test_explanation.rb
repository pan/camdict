# frozen_string_literal: true
require_relative 'helper'

module Camdict
  class ExplanationTest < Minitest::Test
    def test_get_level
      html = '<span class="def-info"><span class="epp-xref B1">B1</span>'
      html = Nokogiri::HTML(html)
      exp  = Camdict::Explanation.new(html)
      assert_equal 'B1', exp.level
    end

    def test_get_meaning
      html = '<span class="def">in <a class="query" href="http://cambridge' \
             '.org/british">agreement </a>with the true facts or with what ' \
             'is generally accepted:'
      html = Nokogiri::HTML(html)
      exp  = Camdict::Explanation.new(html)
      expected =
        'in agreement with the true facts or with what is generally accepted:'
      assert_equal expected, exp.meaning
    end

    def test_code
      # rubber has region, usage, gc
      html = '<span class="def-info"><span class="gcs">U</span>'
      html = Nokogiri::HTML(html)
      exp  = Camdict::Explanation.new(html)
      assert_equal 'U', exp.code
    end

    def test_get_sentence
      html = '<span class="eg">a correct answer</span>'
      html = Nokogiri::HTML(html)
      exp  = Camdict::Sentence.new(html)
      assert_equal 'a correct answer', exp.sentence
    end

    def test_get_examples
      sent1 = %(It's not correct to describe them as 'student')
      sent2 = %("Your name is Angela Black?""That is correct.")
      html  = "<span class='examp'><span class='eg'>#{sent1}</span></span>"
      html += "<span class='examp'><span class='eg'>#{sent2}</span>" \
              '<span class="usage">formal</span>'
      html = Nokogiri::HTML(html)
      e1, e2 = Camdict::Explanation.new(html).examples
      assert_equal sent1, e1.sentence
      assert_equal sent2, e2.sentence
      assert_equal 'formal', e2.usage
    end

    def test_get_synonym
      html = '<span class="entry-xref" type="Synonym"><span class="x-h">right'
      html = Nokogiri::HTML(html)
      exp  = Camdict::Explanation.new(html)
      assert_equal 'right', exp.synonym
    end

    def test_get_opposite
      html =
        '<span class="entry-xref" type="Opposite"><span class="x-h">incorrect'
      html = Nokogiri::HTML(html)
      exp  = Camdict::Explanation.new(html)
      assert_equal 'incorrect', exp.opposite
    end
  end
end
